require 'imro/imro'
require 'imro/activation'
require 'imro/promoter'

class Imro::OutputGene

	attr_reader \
		:promoter,
		:activation,
		:threshold

	# new_random
	def self.new_random(options)
		promoter   = options[:promoter  ] || (raise ArgumentError)
		activation = options[:activation] || (raise ArgumentError)
		index      = options[:index     ] || (raise ArgumentError)

		# result
		self.new(
			:promoter       => Imro::Promoter.new_random(promoter),
			:activation     => Imro::Activation.new_random(activation),
			:threshold      => 2.0 * (rand - 0.5),
			:mutation_delta => 0.25
		)
	end

	# from hash
	def self.from_hash(hash)
		self.new(
			:promoter       => Imro::Promoter.from_hash(  hash[:promoter  ] || (raise ArgumentError)),
			:activation     => Imro::Activation.from_hash(hash[:activation] || (raise ArgumentError)),
			:threshold      => (hash[:threshold     ] || (raise ArgumentError)),
			:mutation_delta => (hash[:mutation_delta] || (raise ArgumentError)))
	end

	# ctor
	def initialize(options)
		@promoter       = options[:promoter      ] || (raise ArgumentError)
		@activation     = options[:activation    ] || (raise ArgumentError)
		@threshold      = options[:threshold     ] || (raise ArgumentError)
		@mutation_delta = options[:mutation_delta] || (raise ArgumentError)
	end

	# clone
	def clone
		Imro::OutputGene.new(
			:promoter       => @promoter,
			:activation     => @activation,
			:threshold      => @threshold,
			:mutation_delta => @mutation_delta)
	end

	# get output
	def output(state, output_type)
		value = @activation.output(@promoter.output(state))

		case(output_type)
		when :boolean; value > 0.0
#		when :boolean; @threshold > 0.0 ? value >= @threshold           : value <= -@threshold
		when :real   ; @threshold > 0.0 ? [value - @threshold, 0.0].max : -([value, -@threshold].min + @threshold)
		else raise ArgumentError end
	end

	# mutate this
	def mutate!(mutation_rate)
		@promoter.mutate!(  mutation_rate)
		@activation.mutate!(mutation_rate)
		@threshold += 2.0 * (rand - 0.5) * @mutation_delta if rand < mutation_rate
	end
		
	# crossover
	def crossover(gene)
		Imro::OutputGene.new(
			:promoter       => [@promoter  , gene.promoter  ][rand(2)].clone,
			:activation     => [@activation, gene.activation][rand(2)].clone,
			:threshold      => [@threshold , gene.threshold ][rand(2)],
			:mutation_delta => @mutation_delta)
	end

	# to_s
	def to_s
		"output P:#{@promoter} A:#{@activation} T:#{@threshold}"
	end

	# to hash
	def to_hash
		{
			:promoter       => @promoter.to_hash,
			:activation     => @activation.to_hash,
			:threshold      => @threshold,
			:mutation_delta => @mutation_delta
		}
	end
end # Imro::OutputGene

