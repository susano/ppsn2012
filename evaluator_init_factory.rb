require 'dynamics/dynamical_system'
#require 'dynamics/dynamical_system_cached'
require 'dynamics/dynamical_system_problem'
require 'dynamics/acrobot_dynamics'
require 'dynamics/pole_balancing_dynamics'
require 'dynamics/jointed_pole_balancing_dynamics'
require 'evaluator'
require 'ode_integration/euler_integrator'
require 'ode_integration/runge_kutta_integrator'
require 'utils/numeric_bind'

require 'pp'

#--
# TODO: optional velocities
class EvaluatorInitFactory

	# from definition
	def self.from_definition(definition)

		# aux: inputs scaler preprocessing
		inputs_scaler_gen = lambda{ |scales|
			lambda{ |array|
				assert{ array.size == scales.size }
				
				Array.new(array.size){ |i| array[i] * scales[i] }
			}
		}

		# aux: inputs_mapping lambda generator
		inputs_mapping_gen = lambda{ |mapping|
			lambda{ |state|
				mapping.collect{ |pos, level| state[pos][level] }
			}
		}

		case(definition[:name])

		# acrobot
		when :acrobot

			max_update_count = definition[:max_update_count] || (raise ArgumentError)

			# 5Hz
#			timestep   = 0.2
#			step_count = 4 * 2

			# 20Hz
			timestep   = 0.05
			step_count = 2

			lambda do 
				# dynamics
				dynamics = AcrobotDynamics.new

				# integrator
				integrator = RungeKuttaIntegrator.new(
					:timestep   => timestep,
					:step_count => step_count)

				# dynamical system
				system = DynamicalSystem.new(
					:dynamics      => dynamics,
					:integrator    => integrator,
					:input_mapping => [[2, 0]]
				)

				# input setup type
#				input_type = :coarse
#				input_type = :direct
				input_type = :trigonometric

				# setup
				setup = 
					case(input_type)

					# inputs: coarse
					when :coarse
						{
							:input_count    => 14,
							:inputs_mapping =>
								lambda do |state|

									t1, t1p = state[0]
									t2, t2p = state[1]

									index_t1 = ((t1 + Math::PI) / (Math::PI / 3.0)).floor.bind(0, 5)
									index_t2 = ((t2 + Math::PI) / (Math::PI / 3.0)).floor.bind(0, 5)

									a1 = Array.new(6, 0.0); a1[index_t1] = 1.0
									a2 = Array.new(6, 0.0); a2[index_t2] = 1.0

									a1 + a2 + [t1p, t2p]
								end,
							:inputs_preprocessing => inputs_scaler_gen.call(Array.new(2 * 6, 1.0) + [1.0 / (Math::PI * 4.0), 1.0 / (Math::PI * 9.0)])
						}

					# inputs: direct
					when :direct
						{
							:input_count          => 4,
							:inputs_mapping       => inputs_mapping_gen.call([[0, 0], [0, 1], [1, 0], [1, 1]]),
							:inputs_preprocessing => inputs_scaler_gen.call([
								1.0 /  Math::PI,
								1.0 / (Math::PI * 4.0),
								1.0 /  Math::PI,
								1.0 / (Math::PI * 9.0)
							])
						}

					# inputs: trigonometric
					when :trigonometric
						{
							:input_count    => 6,
							:inputs_mapping =>
								lambda do |state|
									t1, t1p = state[0]
									t2, t2p = state[1]

									[
										Math::sin(t1),
										Math::cos(t1),
										Math::sin(t2),
										Math::cos(t2),
										t1p,
										t2p
									]
								end,
							:inputs_preprocessing => inputs_scaler_gen.call([
								1.0,
								1.0,
								1.0,
								1.0,
								1.0 / (Math::PI * 4.0),
								1.0 / (Math::PI * 9.0)
							])
						}
					end


				# failure function
				failure_function = lambda{ |state| dynamics.balanced?(state) }
#				failure_function = lambda{ |state| false }

				# reward function
				reward_function  = lambda{ |state| dynamics.balanced?(state) ? 0.0 : -1.0 }
#				reward_function  = lambda{ |state| dynamics.tip_height(state) }
#				reward_function  = lambda{ |state| (
#					upright_angle = (0.3 * Math::PI)
#					((Math::PI - upright_angle)..(Math::PI + upright_angle)).include?(state[0][0]) &&
#					(-upright_angle..upright_angle).include?(state[1][0])) ? 0.0 : -1.0
#				}

				Evaluator.new(DynamicalSystemProblem.new(
					:system               => system,
					:control_type         => :bang_zero_bang,
					:reward_function      => reward_function,
					:failure_function     => failure_function,
					:inputs_mapping       => setup[:inputs_mapping      ],
					:inputs_preprocessing => setup[:inputs_preprocessing],
					:input_count          => setup[:input_count         ],
					:max_update_count     => max_update_count,
					:description          => 'acrobot'
				))
			end

		# zpb
		when :zero_pole_balancing
			raise NotImplementedError

		# spb
		when :single_pole_balancing

			fitness_max   = definition[:fitness_max  ] || (raise ArgumentError)
			pole_length   = definition[:pole_length  ] || 1.0
			range_01      = definition[:range_01     ] || false
			no_velocities = definition[:no_velocities] || false

			timestep  = 0.02
			track_max = 2.4
			angle_max = Math::PI * 12.0 / 180.0

			# aux: inputs scaler preprocessing
			inputs_scaler_gen = lambda{ |scales|
				lambda{ |array|
					assert{ array.size == scales.size }
					
					Array.new(array.size){ |i| array[i] * scales[i] }
				}
			}

			lambda do 
				# dynamics
				dynamics = PoleBalancingDynamics.new([{
						:mass    => 0.1,
						:length  => pole_length,
						:initial => 0.0
					}])

				# integrator
				integrator = RungeKuttaIntegrator.new(
					:timestep   => timestep,
					:step_count => 2)

				# dynamical system
				system = DynamicalSystem.new(
					:dynamics       => dynamics,
					:integrator     => integrator,
					:input_mapping => [[2, 0]]
				)

				# input count
				input_count = no_velocities ? 2 : 4

				# input scaling
				inputs_scaling =
					no_velocities ? [
							1.0 / track_max,
							1.0 / angle_max
						] : [
							1.0 / track_max,
							1.0 / 6.0,
							1.0 / angle_max,
							1.0 / 6.0
						]

				# inputs preprocessing
				inputs_processing = 
					range_01 ?
						lambda do |array|
							assert{ array.size == inputs_scaling.size }
							Array.new(array.size){ |i| ((array[i] * inputs_scaling[i]) + 1.0) / 2.0 }
						end : inputs_scaler_gen.call(inputs_scaling)

				# inputs mapping
				inputs_mapping = inputs_mapping_gen.call(no_velocities ? [[0, 0], [1, 0]] : [[0, 0], [0, 1], [1, 0], [1, 1]])

				# failure function
				failure_function = lambda { |state| !(
					(-track_max..track_max).include?(state[0][0]) &&
					(-angle_max..angle_max).include?(state[1][0]))
				}

				# reward function
				reward_function  = lambda{ |state| failure_function.call(state) ? 0.0 : 1.0 }

				# description
				description = no_velocities ? 'spb_nv' : 'spb'

				Evaluator.new(DynamicalSystemProblem.new(
					:system               => system,
					:control_type         => :bang_bang,
					:reward_function      => reward_function,
					:failure_function     => failure_function,
					:inputs_mapping       => inputs_mapping,
					:inputs_preprocessing => inputs_processing,
					:input_count          => input_count,
					:max_update_count     => fitness_max,
					:description          => description
				))
			end

		# dpb
		when :double_pole_balancing
			fitness_max   = definition[:fitness_max  ] || (raise ArgumentError)
			range_01      = definition[:range_01     ] || false
			no_velocities = definition[:no_velocities] || false

			timestep   = 0.02
			step_count = 2

			track_max = 2.4
			angle_max = Math::PI * 36.0 / 180.0

			lambda do 
				# dynamics
				dynamics = PoleBalancingDynamics.new([{
						:mass    => 0.1,
						:length  => 1.0,
						:initial => 4.0 * Math::PI / 180.0
					}, {
						:mass    => 0.01,
						:length  => 0.1,
						:initial => 0.0
					}])

				# integrator
				integrator = RungeKuttaIntegrator.new(
					:timestep   => timestep,
					:step_count => step_count)

				# system
				system = DynamicalSystem.new(
					:dynamics      => dynamics,
					:integrator    => integrator,
					:input_mapping => [[3, 0]]
				)

				# input count
				input_count = no_velocities ? 3 : 6

				# Stanley and co
#				inputs_scaling = [
#					1.0 / 4.8,
#					1.0 / 6.0,
#					1.0 / 0.52,
#					1.0 / 2.0,
#					1.0 / 0.52,
#					1.0 / 2.0
#				]

				# inputs scaling
				inputs_scaling =
					no_velocities ? [
							1.0 / track_max, 
							1.0 / angle_max,
							1.0 / angle_max,
						] : [
							1.0 / track_max, 
							1.0 / 6.0,
							1.0 / angle_max,
							1.0 / 6.0,
							1.0 / angle_max,
							1.0 / 24.0
						]

				# inputs mapping
				inputs_mapping = inputs_mapping_gen.call(
					no_velocities ? [
							[0, 0], # x
							[1, 0], # t1
							[2, 0] # t2
						] : [
							[0, 0], # x
							[0, 1], # x'
							[1, 0], # t1
							[1, 1], # t1'
							[2, 0], # t2
							[2, 1]  # t2'
						])

				# inputs processing
				inputs_processing = 
					range_01 ?
						lambda do |array|
							assert{ array.size == inputs_scaling.size }
							
							Array.new(array.size){ |i| 0.5 + array[i] * inputs_scaling[i] / 2.0 }
						end : inputs_scaler_gen.call(inputs_scaling)

				# failure function
				failure_function = lambda { |state| !(
					(-track_max..track_max).include?(state[0][0]) &&
					(-angle_max..angle_max).include?(state[1][0]) &&
					(-angle_max..angle_max).include?(state[2][0]))
				}

				# reward function
				reward_function  = lambda{ |state| failure_function.call(state) ? 0.0 : 1.0 }

				# description
				description = no_velocities ? 'dpb_nv' : 'dpb'

				Evaluator.new(DynamicalSystemProblem.new(
					:system               => system,
					:control_type         => :bang_bang,
					:reward_function      => reward_function,
					:failure_function     => failure_function,
					:inputs_mapping       => inputs_mapping,
					:inputs_preprocessing => inputs_processing,
					:input_count          => input_count,
					:max_update_count     => fitness_max,
					:description          => description
				))
			end

		# dpb
		when :jointed_pole_balancing

			fitness_max = definition[:fitness_max] || (raise ArgumentError)
			range_01    = definition[:range_01   ] || false

			timestep   = 0.02
			step_count = 2

			track_max = 2.4
#			angle_max = Math::PI * 36.0 / 180.0
			angle_max = Math::PI * 12.0 / 180.0

			lambda do 
				dynamics = JointedPoleBalancingDynamics.new

				integrator = RungeKuttaIntegrator.new(
					:timestep   => timestep,
					:step_count => step_count)

				system = DynamicalSystem.new(
					:dynamics      => dynamics,
					:integrator    => integrator,
					:input_mapping => [[3, 0]]
				)

				input_count = 6

#				inputs_scaling = [
#					1.0 / 2.4,
#					1.0 / 6.0,
#					1.0 / (Math::PI * 36.0 / 180.0),
#					1.0 / 22.0,
#					1.0 / (Math::PI * 36.0 / 180.0),
#					1.0 / 22.0
#				]

				inputs_scaling = [
					1.0 / 4.8,
					1.0 / 6.0,
					1.0 / 0.52,
					1.0 / 2.0,
					1.0 / 0.52,
					1.0 / 2.0
				]

#				inputs_scaling = inputs_scaling.collect{ |v| v / 11.0 }

				inputs_processing = 
					range_01 ?
						lambda do |array|
							assert{ array.size == inputs_scaling.size }
							
							Array.new(array.size){ |i| 0.5 + array[i] * inputs_scaling[i] / 2.0 }
						end : inputs_scaler_gen.call(inputs_scaling)

				inputs_mapping = [
					[0, 0], # x
					[0, 1], # x'
					[1, 0], # t1
					[1, 1], # t1'
					[2, 0], # t2
					[2, 1]  # t2'
				]

				failure_function = lambda { |state| !(
					(-track_max..track_max).include?(state[0][0]) &&
					(-angle_max..angle_max).include?(state[1][0]) &&
					(-angle_max..angle_max).include?(state[2][0]))
				}

				reward_function  = lambda{ |state| failure_function.call(state) ? 0.0 : 1.0 }

				Evaluator.new(DynamicalSystemProblem.new(
					:system               => system,
					:control_type         => :bang_bang,
					:reward_function      => reward_function,
					:failure_function     => failure_function,
					:inputs_mapping       => inputs_mapping_gen.call(inputs_mapping),
					:inputs_preprocessing => inputs_processing,
					:input_count          => 6,
					:max_update_count     => fitness_max,
					:description          => 'jpb'
				))
			end

		else raise ArgumentError end
	end

end # EvaluatorFactory

