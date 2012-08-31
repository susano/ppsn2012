require 'rnn/rnn'

# weights : [inputs, bias, node outputs]
class Rnn::Controller

	attr_writer :inputs
	attr_reader :outputs

	# ctor
	def initialize(genome, output_type)
		@genome      = genome
		@output_type = output_type

		nodes = @genome.nodes

		@outputs  = Array.new(@genome.output_count, 0.0)
		@previous = Array.new(nodes.size, 0.0)
	end

	# update
	def update
		output_count = @genome.output_count
		nodes        = @genome.nodes
		recurrent    = @genome.recurrent

		inputs = @inputs + [1.0]
		inputs += @previous if recurrent

		values = nodes.collect{ |n| n.execute(inputs) }

		case(@output_type)
		when :real   ; output_count.times{ |i| @outputs[i] = values[i]       }
		when :boolean; output_count.times{ |i| @outputs[i] = values[i] > 0.0 }
		else raise RuntimeError end

		@previous = Array.new(nodes.size){ |i| nodes[i].output } if recurrent # previous
	end

	def reward(v)     ; end # reward
	def signal_failure; end # signal failure
end # Rnn::Controller

