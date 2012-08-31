require 'imro/imro'
require 'imro/controller'
require 'imro/input_gene_protein'
require 'imro/output_gene'
require 'imro/regulatory_gene'

class Imro::Genome

	attr_reader \
		:input_genes,
		:output_genes,
		:regulatory_genes

	# new random
	def self.new_random(definition)
		# gene counts
		input_count      = definition[:input_count     ] || (raise ArgumentError)
		output_count     = definition[:output_count    ] || (raise ArgumentError)
		regulatory_count = definition[:regulatory_count] || (raise ArgumentError)

		# component definitions
		input          = definition[:input         ] || (raise ArgumentError)
		promoter       = definition[:promoter      ] || (raise ArgumentError)
		activation     = definition[:activation    ] || (raise ArgumentError)
		protein_output = definition[:protein_output] || (raise ArgumentError)
		mpp            = definition[:mpp           ] || (raise ArgumentError)

#		promoter_vector_size = input_count + mpp[:protein_vector_size]
		promoter_vector_size = mpp[:protein_vector_size]

		promoter_hash = promoter.merge(
			:promoter_vector_size => promoter_vector_size)

		# result
		self.new(
			:input_genes => Array.new(input_count){ |i|
#				Imro::InputGene.new_random(
#					:definition => input,
#					:index      => i)},
				Imro::InputGeneProtein.new_random(
					:definition => input.merge(:protein_output => protein_output.merge(mpp)),
					:index      => i)},
			:output_genes => Array.new(output_count){ |i|
				Imro::OutputGene.new_random(
					:promoter   => promoter_hash,
					:activation => activation,
					:index      => i)},
			:regulatory_genes => Array.new(regulatory_count){ |i|
				Imro::RegulatoryGene.new_random(
					:promoter       => promoter_hash,
					:activation     => activation,
					:protein_output => protein_output.merge(mpp),
					:index          => i)},
			:mpp_definition => mpp)
	end

	# from hash
	def self.from_hash(hash)
		self.new(
			:input_genes      => (hash[:input_genes     ] || (raise ArgumentError)).collect{ |h| Imro::InputGeneProtein.from_hash(h) },
			:regulatory_genes => (hash[:regulatory_genes] || (raise ArgumentError)).collect{ |h| Imro::RegulatoryGene.from_hash(h)   },
			:output_genes     => (hash[:output_genes    ] || (raise ArgumentError)).collect{ |h| Imro::InputGeneProtein.from_hash(h) },
			:mpp_definition   => (hash[:mpp_definition  ] || (raise ArgumentError)))
	end

	# ctor
	def initialize(options)
		@input_genes      = options[:input_genes     ] || (raise ArgumentError)
		@regulatory_genes = options[:regulatory_genes] || (raise ArgumentError)
		@output_genes     = options[:output_genes    ] || (raise ArgumentError)
		@mpp_definition   = options[:mpp_definition  ] || (raise ArgumentError)
	end

	# clone
	def clone
		Imro::Genome.new(
			:input_genes      => @input_genes.collect{      |g| g.clone },
			:regulatory_genes => @regulatory_genes.collect{ |g| g.clone },
			:output_genes     => @output_genes.collect{     |g| g.clone },
			:mpp_definition   => @mpp_definition)
	end

	# mutate this
	def mutate!(mutation_rate)
		@input_genes.each{      |g| g.mutate!(mutation_rate) }
		@output_genes.each{     |g| g.mutate!(mutation_rate) }
		@regulatory_genes.each{ |g| g.mutate!(mutation_rate) }

		self
	end

	# crossover
	def crossover(genome)
		# self: genes
		self_inputs      = @input_genes
		self_outputs     = @output_genes
		self_regulatory  = @regulatory_genes

		# other: genes
		other_inputs      = genome.input_genes
		other_outputs     = genome.output_genes
		other_regulatory  = genome.regulatory_genes

		# ensure sizes match
		assert{ self_inputs.size      == other_inputs.size      }
		assert{ self_outputs.size     == other_outputs.size     }
		assert{ self_regulatory.size  == other_regulatory.size  }

		# actual crossover
		inputs      = Array.new(self_inputs.size    ){ |i| self_inputs[    i].crossover(other_inputs[     i]) }
		outputs     = Array.new(self_outputs.size   ){ |i| self_outputs[   i].crossover(other_outputs[    i]) }
		regulatory  = Array.new(self_regulatory.size){ |i| self_regulatory[i].crossover(other_regulatory[ i]) }

		# result
		Imro::Genome.new(
			:input_genes      => inputs,
			:output_genes     => outputs,
			:regulatory_genes => regulatory,
			:mpp_definition   => @mpp_definition)
	end

	# new controller
	def new_controller(input_count, output_count, input_type = :update, output_type = :boolean)
		assert{ input_count  == @input_genes.size  }
		assert{ output_count == @output_genes.size }

		Imro::Controller.new(
			:genome         => self,
			:output_type    => output_type,
			:mpp_definition => @mpp_definition)
	end

	# to_s
	def to_s
		result = ''
		@input_genes.each{      |n| result += "#{n}\n" }
		@regulatory_genes.each{ |n| result += "#{n}\n" }
		@output_genes.each{     |n| result += "#{n}\n" }

		result
	end

	# to hash
	def to_hash
		{
			:input_genes      => @input_genes.collect{      |g| g.to_hash },
			:regulatory_genes => @regulatory_genes.collect{ |g| g.to_hash },
			:output_genes     => @output_genes.collect{     |g| g.to_hash },
			:mpp_definition   => @mpp_definition.clone
		}
	end
end # Imro::Genome

