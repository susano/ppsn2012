
class DynamicalSystem
	attr_accessor :state
	attr_reader :dynamics, :inputs
	
	# ctor
	def initialize(options)
		@dynamics      = options[:dynamics     ] || (raise ArgumentError)
		@integrator    = options[:integrator   ] || (raise ArgumentError)
		@input_mapping = options[:input_mapping] || (raise ArgumentError)

		@inputs = Array.new(@input_mapping.size, 0.0)

		reset
	end

	# reset
	def reset 
		@state = @dynamics.initial_state.collect{ |e| e.clone }

		@integrator.init(@dynamics)
	end

	# update
	def update
		# inputs update
		@input_mapping.size.times do |i|
			state_index, level = @input_mapping[i]
			@state[state_index][level] = @inputs[i]
		end

		# optional: post process
		@state = @dynamics.post_process(@integrator.next_state(@state)) if @dynamics.respond_to?(:post_process)
	end
end # DynamicalSystem

