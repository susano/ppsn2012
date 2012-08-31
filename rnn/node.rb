require 'rnn/rnn'

class Rnn::Node

	attr_reader :weights, :output

	# new random
	def self.new_random(weight_count)
		self.new(Array.new(weight_count){ rand * 2.0 - 1.0 })
	end

	# from hash
	def self.from_hash(hash)
		weights hash[:weights] || (raise ArgumentError)
		self.new(weights)
	end

	# ctor
	def initialize(weights)
		@weights = weights
		@output  = 0.0
	end

	# mutate this
	def mutate!(mutation_rate)
		@weights.size.times{ |i| @weights[i] += rand - 0.5 if rand < mutation_rate }
	end

	# crossover
	def crossover(node)
		self_weights  = @weights
		other_weights = node.weights

		Rnn::Node.new(
			Array.new(self_weights.size){ |i| [self_weights, other_weights][rand(2)][i] }
		)
	end

	# clone
	def clone
		Rnn::Node.new(@weights.clone)
	end

	# execute
	def execute(inputs)
		assert{ @weights.size == inputs.size }

		# sum
		sum = 0.0
		inputs.size.times{ |i| sum += @weights[i] * inputs[i] }

		# sigmoid
		@output = Math::tanh(sum)
	end

	# to string
	def to_s
		@weights.collect{ |w| ("%.3f" % w).rjust(7) }.join(', ')
	end

	# to hash
	def to_hash
		{
			:weights => @weights
		}
	end
end # Rnn::Node

