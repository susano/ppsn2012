require 'rnn/rnn'
require 'rnn/controller'
require 'rnn/node'
require 'utils/assert'

class Rnn::Genome

	attr_reader \
		:nodes,
		:input_count,
		:output_count,
		:recurrent

	# new random
	def self.new_random(options)
		input_count  = options[:input_count ] || (raise ArgumentError)
		output_count = options[:output_count] || (raise ArgumentError)
		node_count   = options[:node_count  ] || (raise ArgumentError)
		recurrent    = options[:recurrent   ] || false

		assert{ node_count >= output_count }

		weight_count = input_count + 1
		weight_count += node_count if recurrent

		self.new(
			Array.new(node_count){ Rnn::Node.new_random(weight_count) },
			input_count,
			output_count,
			recurrent
		)
	end

	# from hash
	def self.from_hash(hash)
		nodes = (hash[:nodes] || (raise ArgumentError)).collect{ |n| Rnn::Node.from_hash(n) }
		
		self.new(
			nodes,
			hash[:input_count ] || (raise ArgumentError),
			hash[:output_count] || (raise ArgumentError),
			hash[:recurrent   ] || (raise ArgumentError))
	end

	# ctor
	def initialize(nodes, input_count, output_count, recurrent)
		@nodes        = nodes
		@input_count  = input_count
		@output_count = output_count
		@recurrent    = recurrent
	end

	# clone
	def clone
		Rnn::Genome.new(
			@nodes.collect{ |n| n.clone },
			@input_count,
			@output_count,
			@recurrent
		)
	end

	# mutate this
	def mutate!(mutation_rate)
		@nodes.each{ |n| n.mutate!(mutation_rate) }

		self
	end
	
	# crossover
	def crossover(genome)
		self_nodes  = @nodes
		other_nodes = genome.nodes

		Rnn::Genome.new(
			Array.new(self_nodes.size){ |i| [self_nodes, other_nodes][rand(2)][i].clone },
			@input_count,
			@output_count,
			@recurrent
		)
	end

	# new controller
	def new_controller(input_count, output_count, input_type = :update, output_type = :boolean)
		assert{ input_count  == @input_count  }
		assert{ output_count == @output_count }

		Rnn::Controller.new(self, output_type)
	end

	# to string
	def to_s
		@nodes.collect{ |n| n.to_s }.join("\n") + "\n"
	end

	# to hash
	def to_hash
		{
			:nodes        => @nodes.collect{ |n| n.to_hash },
			:input_count  => @input_count,
			:output_count => @output_count,
			:recurrent    => @recurrent
		}
	end
end # Rnn::Genome

