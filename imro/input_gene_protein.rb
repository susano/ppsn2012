require 'imro/imro'

class Imro::InputGeneProtein

	attr_reader :input_scale, :protein_output


	# new_random
	def self.new_random(options)
		definition = options[:definition] || (raise ArgumentError)
		index      = options[:index     ] || (raise ArgumentError)

		protein_output = definition[:protein_output        ] || (raise ArgumentError)
		init_range     = definition[:input_scale_init_range] || (raise ArgumentError)

		first, last = init_range.first, init_range.last
		scale = first + rand * (last - first)

		mutation_delta = (last - first) / 4.0

		# result
		Imro::InputGeneProtein.new(
			:input_scale    => scale,
			:mutation_delta => mutation_delta,
#			:protein_output => Imro::ProteinOutput.new_random_single(protein_output))
			:protein_output => Imro::ProteinOutput.new_random_single(protein_output.merge(:index => index)))
	end

	# from hash
	def self.from_hash(hash)
		self.new(
			:input_scale    => (hash[:input_scale   ] || (raise ArgumentError)),
			:mutation_delta => (hash[:mutation_delta] || (raise ArgumentError)),
			:protein_output => Imro::ProteinOutput.from_hash(hash[:protein_output] || (raise ArgumentError)))
	end

	# ctor
	def initialize(options)
		@input_scale    = options[:input_scale   ] || (raise ArgumentError)
		@mutation_delta = options[:mutation_delta] || (raise ArgumentError)
		@protein_output = options[:protein_output] || (raise ArgumentError)
	end

	# clone
	def clone
		Imro::InputGeneProtein.new(
			:input_scale    => @input_scale,
			:mutation_delta => @mutation_delta,
			:protein_output => @protein_output.clone)
	end

	# value for an input
	def output(input)
		@protein_output.output_value(input * @input_scale)
	end

	# mutate this
	def mutate!(mutation_rate)
		@input_scale += 2.0 * (rand - 0.5) * @mutation_delta if rand < mutation_rate
		@protein_output.mutate!(mutation_rate)
	end

	# crossover
	def crossover(gene)
		Imro::InputGeneProtein.new(
			:input_scale    => [@input_scale   , gene.input_scale][rand(2)],
			:mutation_delta => @mutation_delta,
			:protein_output => [@protein_output, gene.protein_output][rand(2)].clone)
	end

	# to_s
	def to_s
		"input #{('%.2f' % @input_scale).rjust(6)} #{@protein_output}"
	end

	# to hash
	def to_hash
		{
			:input_scale    => @input_scale,
			:mutation_delta => @mutation_delta,
			:protein_output => @protein_output.to_hash
		}
	end
end # Imro::InputGeneProtein

