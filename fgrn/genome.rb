require 'fgrn/fgrn'
require 'fgrn/controller'
require 'fgrn/gene'
require 'fgrn/running_environmental_gene'
require 'fgrn/running_receptor_gene'
require 'fgrn/running_regulatory_gene'
require 'fgrn/running_behavioural_gene'

class Fgrn::Genome

	attr_reader :genes

	# new random
	def self.new_random(options)
		gene_init       = options[:gene_init      ] || (raise ArgumentError)
		composition     = options[:composition    ] || (raise ArgumentError)
		system_settings = options[:system_settings] || (raise ArgumentError)

		# generate genes
		genes = []
		[:behavioural, :regulatory, :receptor, :environmental].each do |type|
			(composition[type] || 0).times do
				genes << gene_init.call(type, system_settings)
			end
		end

		self.new(genes, system_settings)
	end # new random

	# from hash
	def self.from_hash(hash)
		system_settings = hash[:system_settings]
		genes           = hash[:genes].collect{ |h| Fgrn::Gene.from_hash(h, system_settings) }

		self.new(genes, system_settings)
	end

	# ctor
	def initialize(genes, system_settings)
		@genes           = genes
		@system_settings = system_settings
	end # ctor
	
	# clone
	def clone
		Fgrn::Genome.new(@genes.collect{ |g| g.clone }, @system_settings)
	end # clone

	# new running genes
	def new_running_genes(system_settings)
		environmental_genes = []
		receptor_genes      = []
		regulatory_genes    = []
		behavioural_genes   = []

		genes.each do |g|
			t = g.type
			environmental_genes << Fgrn::RunningEnvironmentalGene.new(g, system_settings) if t.environmental?
			receptor_genes      << Fgrn::RunningReceptorGene.new(     g, system_settings) if t.receptor?
			regulatory_genes    << Fgrn::RunningRegulatoryGene.new(   g, system_settings) if t.regulatory?
			behavioural_genes   << Fgrn::RunningBehaviouralGene.new(  g, system_settings) if t.behavioural?
		end

		{
			:environmental => environmental_genes,
			:receptor      => receptor_genes,
			:regulatory    => regulatory_genes,
			:behavioural   => behavioural_genes
		}
	end
	
	# mutate this
	def mutate!(mutation_rate)
		if (!@genes.empty?) # only for non-empty genomes
			genome_structure_mutations = !!@system_settings[:genome_structure_mutations]
			@genes << @genes[rand(@genes.size)].clone if genome_structure_mutations && rand < mutation_rate # duplicate gene
			@genes.delete_at(rand(@genes.size))       if genome_structure_mutations && rand < mutation_rate # delete gene

			@genes.each{ |gene| gene.mutate!(mutation_rate) if rand <= mutation_rate } # mutate genes
		end

		self
	end

	# crossover
	def crossover(genome)
		self_genes  = self.genes
		other_genes = genome.genes

		min_count = [self_genes.size, other_genes.size].min

		new_genes = Array.new(min_count){ |i| self_genes[i].crossover(other_genes[i]) }

		if (self_genes.size > min_count)
			(min_count...(self_genes.size)).each{ |i| new_genes << self_genes[i].clone }
		end

		Fgrn::Genome.new(new_genes, @system_settings)
	end # crossover

	# new controller
	def new_controller(input_count, output_count, input_type = :update, output_type = :boolean)

		Fgrn::Controller.new(
			:genome          => self,
			:system_settings => @system_settings,
			:input_count     => input_count,
			:output_count    => output_count,
			:input_type      => input_type,
			:output_type     => output_type)
	end # new_controller

	# to hash
	def to_hash
		{
			:genes           => @genes.collect(&:to_hash),
			:system_settings => @system_settings
		}
	end

	# to_s
	def to_s
		@genes.collect{ |gene| gene.to_s + "\n" }.join('')
	end

	# to lines
#	def to_lines
#		line = []
#		f = (((fitness) ? fitness : 0).to_f / 100000.0 * 255.0).to_i
#
#		line << [14, [f, f, f]]
#		@genes.each do |gene|
#			line.concat(gene.to_lines)
#		end
#
#		line
#	end
end # Fgrn::Genome

