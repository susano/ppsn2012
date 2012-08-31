#require 'problem_interface'

#class DynamicalSystemProblem < ProblemInterface
class DynamicalSystemProblem
	attr_reader :input_count, :output_count, :description, :input_type, :output_type, :current_run

	# ctor
	def initialize(options)
		@system               = options[:system              ] || (raise ArgumentError)
		@control_type         = options[:control_type        ] || (raise ArgumentError)
		@reward_function      = options[:reward_function     ] || (raise ArgumentError)
		@failure_function     = options[:failure_function    ] || (raise ArgumentError)
		@inputs_mapping       = options[:inputs_mapping      ] || (raise ArgumentError)
		@inputs_preprocessing = options[:inputs_preprocessing] || nil
		@input_count          = options[:input_count         ] || (raise ArgumentError)
		@description          = options[:description         ] || (raise ArgumentError)
		@max_update_count     = options[:max_update_count    ] || (raise ArgumentError)

		@input_type = :update

		case(@control_type)
		when :bang_bang
			@output_count = 1
			@output_type  = :boolean
		when :bang_zero_bang
			@output_count = 3
			@output_type  = :real
		else raise ArgumentError end

		self.reset
	end

	# reset
	def reset
		@system.reset
		@first_update = true
		@failure      = false
		@current_run  = {
			:actions      => [],
			:score        => 0.0,
			:update_count => 0
		}
	end

	# run once
	def run_once(controller)
		if @first_update
			@first_update = false
			controller.start if controller.respond_to? :start # optional: controller reset
		end

		# checking below max update count
		update_count = @current_run[:update_count] 
		raise RuntimeError, "Running beyond max update count!" if update_count >= @max_update_count

		# system state to controller inputs
		state  = @system.state
		inputs = @inputs_mapping.call(state)
		inputs = @inputs_preprocessing.call(inputs) if @inputs_preprocessing

		# update controller
		controller.inputs = inputs
		controller.update

		# system action from controller output, ATM only one action supported
		outputs = controller.outputs
		f = 
			case(@control_type)
			# bang-bang
			when :bang_bang
				assert{ outputs.size == 1 }

				o = outputs[0]

				if    o == true  then  1.0
				elsif o == false then -1.0
				else raise RuntimeError, "weird output: '#{o.inspect}'" end

			# bang-zero-bang
			when :bang_zero_bang
				assert{ outputs.size == 3 }

				highest_index = 0
				highest_value = outputs[0]

				[1, 2].each do |i|
					o = outputs[i] 
					if o > highest_value
						highest_index = i
						highest_value = o
					end
				end

				[0.0, -1.0, 1.0][highest_index]
			end

		@system.inputs[0] = f
		@current_run[:actions] << f

		# update system
		@system.update
		state = @system.state

		# reward
		r = @reward_function.call(state)
		@current_run[:score] += r
		controller.reward(r)

		# check failure
		if @failure_function.call(state)
			controller.signal_failure
			@failure = true
		end

		# increment update count
		update_count += 1
		@current_run[:update_count] = update_count

		# true if we can continue running, false otherwise
		!@failure && update_count < @max_update_count
	end

	# run
	def run(controller)
		reset
		while run_once(controller); end
		
		@current_run[:score]
	end

#		phenotype = actions.collect{ |r| (r > 0.0) ? '+' : (r < 0.0 ? '-' : '.')}.join
#
#		$current_min_update_count = [update_count, $current_min_update_count].min

#		$stderr << "debug rewards #{score.to_i.to_s.rjust(4)}\n"
#		$stderr << "debug rewards #{score.to_i.to_s.rjust(4)} #{debug_rewards.collect{ |r| (r > 0.0) ? '+' : (r < 0.0 ? '_' : '.')}.join}\n"
#		$stderr << "debug rewards #{score.to_i.to_s.rjust(4)} -  #{debug_rewards.collect{ |r| '%.2f' % r }.join(', ')}\n"

#		$stderr << "debug evaluation #{score.to_i.to_s.rjust(5)} #{phenotype}\n"

		#		FIX reactivate
#		@phenotypes << phenotype unless @phenotypes.include?(phenotype)

#	def phenotype_evaluations
#		@phenotypes.size
#	end

#	def debug_print(state, action)
#		$stderr << "debug timestep #{state[0][0].to_s.rjust(10)}, #{state[0][1].to_s.rjust(10)}, #{state[1][0].to_s.rjust(10)}, #{state[1][1].to_s.rjust(10)}, #{state[2][0].to_s.rjust(10)}, #{state[2][1].to_s.rjust(10)},     action #{action}\n"
#			t1 = state[0][0]
#			t2 = state[0][0]
#
#			t1 = (t1 <=> 0.0) * (t1.abs % (2.0 * Math::PI))
#			t2 = (t2 <=> 0.0) * (t2.abs % (2.0 * Math::PI))
#
#			t1 = (t1 > Math::PI) ? t1 - Math::PI : ((t1 < -Math::PI) ? t1 + Math::PI : t1)
#			t2 = (t2 > Math::PI) ? t2 - Math::PI : ((t2 < -Math::PI) ? t2 + Math::PI : t2)

#			$stderr << "debug counter #{@counter.to_s.rjust(6)} energy #{("%.2f" % @system.dynamics.energy(state)).rjust(10)}  position #{("%.2f" % t1).rjust(6)}  \t#{("%.2f" % t2).rjust(6)}   speed #{("%.2f" % state[0][1]).rjust(6)}  \t#{("%.2f" % state[1][1]).rjust(6)}   #{f}\n"

#			$stderr << "debug counter #{@counter.to_s.rjust(6)}  position #{("%.2f" % t1).rjust(6)}  \t#{("%.2f" % t2).rjust(6)}   speed #{("%.2f" % state[0][1]).rjust(6)}  \t#{("%.2f" % state[1][1]).rjust(6)}   #{f}\n"
#	end
end # DynamicalSystemProblem




#if $0 == __FILE__ || defined? $TESTING
#
#	require 'test/unit'
#
#	class DynamicalSystemProblemTest < Test::Unit::TestCase
#		def test_general
#
#
#			system = DynamicalSystem.new(
#				:dynamics      => dynamics,
#				:integrator    => integrator,
#				:input_mapping => [[2, 0]]
#			)
#				integrator = RungeKuttaIntegrator.new(
#					:timestep   => timestep,
#					:step_count => step_count)
#
#		end
#	end # DynamicalSystemProblem
#end # TESTING

