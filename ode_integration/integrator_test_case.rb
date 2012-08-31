require 'test/unit'
require 'dynamical_system'

class IntegratorTestCase < Test::Unit::TestCase

	def generate_test(integrator_class, testing_data)
		testing_data.each do |data|
			# integrator
			integrator = integrator_class.new(
				:timestep     => data[:timestep    ],
				:step_count   => data[:step_count  ],
				:initial_time => data[:initial_time])

			# dynamical system
			dynamical_system = DynamicalSystem.new(
				:dynamics      => data[:dynamics],
				:integrator    => integrator,
				:input_mapping => [])

			# update
			data[:iterations].times do |i|
				dynamical_system.update
			end

			# check end state
			end_state = dynamical_system.state
			desired_state = data[:desired_state]
			float_error   = data[:float_error]
			desired_state.size.times do |i|
				v = desired_state[i]
				v.size.times do |j|
					desired  = v[j]
					obtained = end_state[i][j]
					$stderr << "debug test desired #{desired.to_s.rjust(22)} obtained #{obtained.to_s.rjust(22)} diff #{obtained - desired}\n"
					assert_in_delta(desired, obtained, float_error)
				end
			end
		end # testing_data.each
	end # generate_test
end # IntegratorTestCase

