require 'imro/imro'

# LATER fix evolvabitlity threshold
class Imro::Activation

	attr_reader \
		:input_scale,
		:threshold

	# new random
	def self.new_random(options)
		input_scale_init_range = options[:input_scale_init_range] || (raise ArgumentError)
		k                      = options[:k                     ] || (raise ArgumentError)
		activation_type        = options[:activation_type       ] || (raise ArgumentError)

		# input_scale
		range_first = input_scale_init_range.first
		range_last  = input_scale_init_range.last
		input_scale = range_first + rand * (range_last - range_first)

		# threshold [-1,1]
		threshold = rand * 2.0 - 1.0 

		# result
		self.new(
			:type           => activation_type,
			:input_scale    => input_scale,
			:threshold      => threshold,
			:k              => k,
			:mutation_delta => {
				:input_scale => (range_last - range_first) / 4.0,
				:threshold   => 0.5 })
	end

	# from hash
	def self.from_hash(hash)
		self.new(
			:type           => (hash[:type          ] || (raise ArgumentError)),
			:input_scale    => (hash[:input_scale   ] || (raise ArgumentError)),
			:threshold      => (hash[:threshold     ] || (raise ArgumentError)),
			:k              => (hash[:k             ] || (raise ArgumentError)),
			:mutation_delta => (hash[:mutation_delta] || (raise ArgumentError)))
	end

	# ctor
	def initialize(options)
		@type           = options[:type          ] || (raise ArgumentError)
		@input_scale    = options[:input_scale   ] || (raise ArgumentError)
		@threshold      = options[:threshold     ] || (raise ArgumentError)
		@k              = options[:k             ] || (raise ArgumentError)
		@mutation_delta = options[:mutation_delta] || (raise ArgumentError)
	end

	# clone
	def clone
		Imro::Activation.new(
			:type           => @type,
			:input_scale    => @input_scale,
			:threshold      => @threshold,
			:k              => @k,
			:mutation_delta => @mutation_delta)
	end

	# output
	def output(input)
		case(@type)
		when :tanh_thresholded
			v = (Math::tanh(@k * @input_scale * input) + 1.0) / 2.0
			if @threshold > 0
				if @threshold < 0.999999
					([v, @threshold].max - @threshold) / (1.0 - @threshold)
				else
					1.0
				end
 			else
				if @threshold.abs > 0.000_000_1
					[v, -@threshold].min / -@threshold
				else
					0.0
				end
			end
		when :tanh
			Math::tanh(@k * @input_scale * input) - @threshold
		else raise ArgumentError end
	end

	# mutate this
	# LATER FIX smoothen mutation
	def mutate!(mutation_rate)
		@input_scale += 2.0 * (rand - 0.5) * @mutation_delta[:input_scale] if rand < mutation_rate
		if rand < mutation_rate
			@threshold += 2.0 * (rand - 0.5) * @mutation_delta[:threshold  ]
			@threshold =  1.0 if @threshold >  1.0
			@threshold = -1.0 if @threshold < -1.0
		end
	end
		
	# crossover
	def crossover(gene)
		Imro::Activation.new(
			:input_scale    => [@input_scale, gene.input_scale][rand(2)],
			:threshold      => [@threshold  , gene.threshold  ][rand(2)],
			:k              => @k,
			:mutation_delta => @mutation_delta)
	end

	# to_s
	def to_s
		"S:#{("%.2f" % @input_scale).rjust(6)}  T:#{("%.2f" % @threshold).rjust(6)}"
	end

	# to hash
	def to_hash
		{
			:type           => @type,
			:input_scale    => @input_scale,
			:threshold      => @threshold,
			:k              => @k,
			:mutation_delta => @mutation_delta.clone
		}
	end
end # Imro::Activation

