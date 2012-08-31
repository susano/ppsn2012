require 'imro/imro'

class Imro::Promoter

	attr_reader \
		:weights,
		:masks

	# new random
	def self.new_random(options)
		weights_init_range     = options[:weights_init_range    ] || (raise ArgumentError)
		masks_init_probability = options[:masks_init_probability] || (raise ArgumentError)
		promoter_vector_size   = options[:promoter_vector_size  ] || (raise ArgumentError)
		weights_init_range     = options[:weights_init_range    ] || (raise ArgumentError)

		init_range_first = weights_init_range.first
		init_range_last  = weights_init_range.last
		weights = Array.new(promoter_vector_size){ init_range_first + rand * (init_range_last - init_range_first) }
		masks   = Array.new(promoter_vector_size){ rand < masks_init_probability }

		mutation_delta = (init_range_last - init_range_first) / 4.0

		self.new(
			:weights        => weights,
			:masks          => masks,
			:mutation_delta => mutation_delta)
	end

	# from hash
	def self.from_hash
		self.new(
			:weights        => (hash[:weights       ] || (raise ArgumentError)),
			:masks          => (hash[:masks         ] || (raise ArgumentError)),
			:mutation_delta => (hash[:mutation_delta] || (raise ArgumentError)))
	end

	# ctor
	def initialize(options)
		@weights        = options[:weights       ] || (raise ArgumentError)
		@masks          = options[:masks         ] || (raise ArgumentError)
		@mutation_delta = options[:mutation_delta] || (raise ArgumentError)
	end

	# clone
	def clone
		Imro::Promoter.new(
			:weights        => @weights.clone,
			:masks          => @masks.clone,
			:mutation_delta => @mutation_delta)
	end

	# output
	def output(state)
		sum = 0.0
		@weights.size.times do |i|
			sum += @weights[i] * state[i] if @masks[i]
		end

		sum
	end

	# mutate this
	def mutate!(mutation_rate)
		size = @weights.size
		size.times do |i|
			@weights[i] += 2.0 * (rand - 0.5) * @mutation_delta if rand < mutation_rate
			@masks[  i] = !@masks[i]                            if rand < mutation_rate
		end
	end
		
	# crossover
	def crossover(gene)
		# self
		weights = @weights
		masks   = @masks

		# other
		other_weights = gene.weights
		other_masks   = gene.masks

		# result
		Imro::Promoter.new(
			:weights        => Array.new(weights.size){ |i| [weights[i], other_weights[i]][rand(2)] },
			:masks          => Array.new(masks.size  ){ |i| [masks[  i], other_masks[  i]][rand(2)] },
			:mutation_delta => @mutation_delta)
	end

	# to_s
	def to_s
		"|#{@weights.collect.with_index{ |w, i| (@masks[i]) ? ("%.2f" % w).rjust(6) : '      ' }.join('|')}|"
	end

	# to hash
	def to_hash
		{
			:weights        => @weights.clone,
			:masks          => @masks.clone,
			:mutation_delta => @mutation_delta
		}
	end
end # Imro::Promoter

