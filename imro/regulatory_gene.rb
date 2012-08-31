require 'imro/imro'
require 'imro/activation'
require 'imro/promoter'
require 'imro/protein_output'

class Imro::RegulatoryGene

	attr_reader \
		:promoter,
		:activation,
		:protein_output

	# new_random
	def self.new_random(options)
		promoter       = options[:promoter      ] || (raise ArgumentError)
		activation     = options[:activation    ] || (raise ArgumentError)
		protein_output = options[:protein_output] || (raise ArgumentError)
		index          = options[:index         ] || (raise ArgumentError)

		# result
		self.new(
			:promoter       => Imro::Promoter.new_random(promoter),
			:activation     => Imro::Activation.new_random(activation),
			:protein_output => Imro::ProteinOutput.new_random(protein_output))
	end

	# from hash
	def self.from_hash(hash)
		self.new(
			:promoter       => Imro::Promoter.from_hash(     hash[:promoter      ] || (raise ArgumentError)),
			:activation     => Imro::Activation.from_hash(   hash[:activation    ] || (raise ArgumentError)),
			:protein_output => Imro::ProteinOutput.from_hash(hash[:protein_output] || (raise ArgumentError)))
	end

	# ctor
	def initialize(options)
		@promoter       = options[:promoter      ] || (raise ArgumentError)
		@activation     = options[:activation    ] || (raise ArgumentError)
		@protein_output = options[:protein_output] || (raise ArgumentError)
	end

	# clone
	def clone
		Imro::RegulatoryGene.new(
			:promoter       => @promoter.clone,
			:activation     => @activation.clone,
			:protein_output => @protein_output.clone)
	end

	# output
	def output(state)
		@protein_output.output(
			@activation.output(
				@promoter.output(state)))
	end

	# mutate this
	def mutate!(mutation_rate)
		@promoter.mutate!(mutation_rate)
		@activation.mutate!(mutation_rate)
		@protein_output.mutate!(mutation_rate)
	end
		
	# crossover
	def crossover(gene)
		Imro::RegulatoryGene.new(
			:promoter       => [@promoter      , gene.promoter      ][rand(2)].clone,
			:activation     => [@activation    , gene.activation    ][rand(2)].clone,
			:protein_output => [@protein_output, gene.protein_output][rand(2)].clone)
	end

	# to_s
	def to_s
		"output P:#{@promoter} A:#{@activation} T:#{@threshold} P:#{@protein_output}"
	end

	# to hash
	def to_hash
		{
			:promoter       => @promoter.to_hash,
			:activation     => @activation.to_hash,
			:protein_output => @protein_output.to_hash
		}
	end
end # Imro::RegulatoryGene

