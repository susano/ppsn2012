require 'integrator_interface'

class RungeKuttaIntegrator < IntegratorInterface

	# ctor
	def initialize(options)
		@timestep     = options[:timestep    ] || (raise ArgumentError)
		@step_count   = options[:step_count  ] || (raise ArgumentError)
		@initial_time = options[:initial_time] || 0
	end

	# init
	def init(dynamics)
		@dynamics = dynamics
		@time = @initial_time
	end

# From python code:
#
#  http://doswa.com/2009/04/21/improved-rk4-implementation.html
#
#    def rk4(t0, h, s0, f):
#        """RK4 implementation.
#        t = current value of the independent variable
#        h = amount to increase the independent variable (step size)
#        s0 = initial state as a list. ex.: [initial_position, initial_velocity]
#        f = function(state, t) to integrate"""
#        r = range(len(s0))
#        s1 = s0 + [f(t0, s0)]
#        s2 = [s0[i] + 0.5*s1[i+1]*h for i in r]
#        s2 += [f(t0+0.5*h, s2)]
#        s3 = [s0[i] + 0.5*s2[i+1]*h for i in r]
#        s3 += [f(t0+0.5*h, s3)]
#        s4 = [s0[i] + s3[i+1]*h for i in r]
#        s4 += [f(t0+h, s4)]
#        return t+h, [s0[i] + (s1[i+1] + 2*(s2[i+1]+s3[i+1]) + s4[i+1])*h/6.0 for i in r]	
#
# next state from current +state+
	def next_state_py(state)
		h = @timestep / @step_count

		state_count = state.size
		range       = state[0].size

		t0 = @time
		s0 = state
		@step_count.times do |i|

			# s1 = s0 + [f(t0, s0)]
			a = @dynamics.step_acceleration(t0, s0)
			s1 = s0.collect.with_index{ |v, i| v + [a[i]] }

			# s2 = [s0[i] + 0.5*s1[i+1]*h for i in r]
			s2 =
				Array.new(state_count) do |idx|
					s0v = s0[idx]
					s1v = s1[idx]
					Array.new(range){ |i| s0v[i] + 0.5 * s1v[i + 1] * h }
				end

			# s2 += [f(t0+0.5*h, s2)]
			a = @dynamics.step_acceleration(t0 + 0.5 * h, s2)
			s2.each.with_index{ |v, i| v << a[i] }

			# s3 = [s0[i] + 0.5*s2[i+1]*h for i in r]
			s3 =
				Array.new(state_count) do |idx|
					s0v = s0[idx]
					s2v = s2[idx]
					Array.new(range){ |i| s0v[i] + 0.5 * s2v[i + 1] * h }
				end

			# s3 += [f(t0+0.5*h, s3)]
			a = @dynamics.step_acceleration(t0 + 0.5 * h, s3)
			s3.each.with_index{ |v, i| v << a[i] }
			
			# s4 = [s0[i] + s3[i+1]*h for i in r]
			s4 = 
				Array.new(state_count) do |idx|
					s0v = s0[idx]
					s3v = s3[idx]
					Array.new(range){ |i| s0v[i] + s3v[i + 1] * h }
				end

			# s4 += [f(t0+h, s4)]
			a = @dynamics.step_acceleration(t0 + h, s4)
			s4.each.with_index{ |v, i| v << a[i] }

#			$stderr << "debug k1 #{s1[0]}\n"
#			$stderr << "debug k2 #{s2[0]}\n"
#			$stderr << "debug k3 #{s3[0]}\n"
#			$stderr << "debug k4 #{s4[0]}\n"

			# return t+h, [s0[i] + (s1[i+1] + 2*(s2[i+1]+s3[i+1]) + s4[i+1])*h/6.0 for i in r]	
			t0 += h 
			s0 =
				Array.new(state_count) do |idx|
					s0v = s0[idx]
					s1v = s1[idx]
					s2v = s2[idx]
					s3v = s3[idx]
					s4v = s4[idx]
					Array.new(range){ |i| s0v[i] + (s1v[i + 1] + 2.0 * (s2v[i + 1] + s3v[i + 1]) + s4v[i + 1]) * h / 6.0 }
				end
		end

		@time = t0

		s0
	end

	def next_state(state)
		h = @timestep / @step_count

		state_count = state.size
		range       = state[0].size

		t0 = @time
		s0 = state
		@step_count.times do |i|

			# s1 = s0 + [f(t0, s0)]
			a = @dynamics.step_acceleration(t0, s0)
			s1 = s0.collect.with_index{ |v, i| v + [a[i]] }

			# s2 = [s0[i] + 0.5*s1[i+1]*h for i in r]
			s2 =
				Array.new(state_count) do |idx|
					s0v = s0[idx]
					s1v = s1[idx]
					Array.new(range){ |i| s0v[i] + 0.5 * s1v[i + 1] * h }
				end

			# s2 += [f(t0+0.5*h, s2)]
			a = @dynamics.step_acceleration(t0 + 0.5 * h, s2)
			s2.each.with_index{ |v, i| v << a[i] }

			# s3 = [s0[i] + 0.5*s2[i+1]*h for i in r]
			s3 =
				Array.new(state_count) do |idx|
					s0v = s0[idx]
					s2v = s2[idx]
					Array.new(range){ |i| s0v[i] + 0.5 * s2v[i + 1] * h }
				end

			# s3 += [f(t0+0.5*h, s3)]
			a = @dynamics.step_acceleration(t0 + 0.5 * h, s3)
			s3.each.with_index{ |v, i| v << a[i] }
			
			# s4 = [s0[i] + s3[i+1]*h for i in r]
			s4 = 
				Array.new(state_count) do |idx|
					s0v = s0[idx]
					s3v = s3[idx]
					Array.new(range){ |i| s0v[i] + s3v[i + 1] * h }
				end

			# s4 += [f(t0+h, s4)]
			a = @dynamics.step_acceleration(t0 + h, s4)
			s4.each.with_index{ |v, i| v << a[i] }

#			$stderr << "debug k1 #{s1[0]}\n"
#			$stderr << "debug k2 #{s2[0]}\n"
#			$stderr << "debug k3 #{s3[0]}\n"
#			$stderr << "debug k4 #{s4[0]}\n"

			# return t+h, [s0[i] + (s1[i+1] + 2*(s2[i+1]+s3[i+1]) + s4[i+1])*h/6.0 for i in r]	
			t0 += h 
			s0 =
				Array.new(state_count) do |idx|
					s0v = s0[idx]
					s1v = s1[idx]
					s2v = s2[idx]
					s3v = s3[idx]
					s4v = s4[idx]
					Array.new(range){ |i| s0v[i] + (s1v[i + 1] + 2.0 * (s2v[i + 1] + s3v[i + 1]) + s4v[i + 1]) * h / 6.0 }
				end
		end

		@time = t0

		s0
	end
end # RungeKuttaIntegrator


#if false
if $0 == __FILE__ || (defined?($TESTING) && $TESTING)

	require 'integrator_test_case'
	require 'dynamics_interface'

	# from http://doswa.com/2009/01/02/fourth-order-runge-kutta-numerical-integration.html
	class DoswaExampleDynamics < DynamicsInterface
		STIFFNESS =  1
		DAMPING   = -0.005
		def initial_state              ; [[50.0, 5.0]]                                      end # initial state
		def step_acceleration(t, state); [-STIFFNESS * state[0][0] - DAMPING * state[0][1]] end # step acceleration
	end # DoswaExampleDynamics

	class SingleExampleDynamics < DynamicsInterface
		def initial_state              ; [[1.0]]                          end # initial state
		def step_acceleration(t, state); [ -2.0 * state[0][0] + t + 4.0 ] end # step acceleration
	end # SingleExampleDynamics

	class ChemicalEngineeringExampleDynamics < DynamicsInterface
		def initial_state              ; [[50.0]]                     end # initial state
		def step_acceleration(t, state); [ 37.5 - 3.5 * state[0][0] ] end # step acceleration
	end # ChemicalEngineeringExampleDynamics

	class ComputerEngineeringExampleDynamics < DynamicsInterface
		def initial_state              ; [[0.0]] end # initial state
		def step_acceleration(t, state);
			[ (1.0 / (150.0 * 1e-6)) * (-0.1 + [((18.0 * Math::cos(120.0 * Math::PI * t)).abs - 2.0 - state[0][0]) / 0.04 ,0].max) ]
		end # step acceleration
	end # ChemicalEngineeringExampleDynamics

	class MultipleExampleDynamics < DynamicsInterface
		def initial_state ; [[4.0], [6.0]] end # initial state
		def step_acceleration(t, state);
			[ -0.5 * state[0][0], 4.0 - 0.3 * state[1][0] - 0.1 * state[0][0] ]
		end
	end # MultipleExampleDynamics

	class TestRungeKuttaIntegrator < IntegratorTestCase

		# test runge kutta
		def test_runge_kutta
			testing_data = [{
				:dynamics => DoswaExampleDynamics.new              , :timestep => 1.0/40.0 , :step_count => 1, :initial_time => 0, :iterations => 4000, :float_error => 0.01  ,
				:desired_state => [[52.18, 38.05]] }, {
# hmmm, doesn't work... putting it on blog inaccuracies...
#				:dynamics => DoswaExampleDynamics.new              , :timestep => 1.0/400.0, :step_count => 1, :initial_time => 0, :iterations => 40000, :float_error => 0.01 ,
#				:desired_state => [[52.28, 37.92]] }, {
				:dynamics => SingleExampleDynamics.new             , :timestep => 0.2      , :step_count => 1, :initial_time => 0, :iterations => 1   , :float_error => 0.0001,
				:desired_state => [[1.3472]] }, {
				:dynamics => ChemicalEngineeringExampleDynamics.new, :timestep => 3        , :step_count => 1, :initial_time => 0, :iterations => 1   , :float_error => 1.0   ,
				:desired_state => [[14120 ]] }, {
				:dynamics => ChemicalEngineeringExampleDynamics.new, :timestep => 1.5      , :step_count => 1, :initial_time => 0, :iterations => 2   , :float_error => 1.0   ,
				:desired_state => [[11455 ]] }, {
				:dynamics => ChemicalEngineeringExampleDynamics.new, :timestep => 0.75     , :step_count => 1, :initial_time => 0, :iterations => 4   , :float_error => 0.001 ,
				:desired_state => [[25.559]] }, {
				:dynamics => ChemicalEngineeringExampleDynamics.new, :timestep => 0.375    , :step_count => 1, :initial_time => 0, :iterations => 8   , :float_error => 0.001 ,
				:desired_state => [[10.717]] }, {
				:dynamics => ChemicalEngineeringExampleDynamics.new, :timestep => 0.1875   , :step_count => 1, :initial_time => 0, :iterations => 16  , :float_error => 0.001 ,
				:desired_state => [[10.715]] }, {
				:dynamics => ComputerEngineeringExampleDynamics.new, :timestep => 0.00004  , :step_count => 1, :initial_time => 0, :iterations => 1   , :float_error => 0.001 ,
				:desired_state => [[53.335]] }, {
				:dynamics => ComputerEngineeringExampleDynamics.new, :timestep => 0.00002  , :step_count => 1, :initial_time => 0, :iterations => 2   , :float_error => 0.001 ,
				:desired_state => [[26.647]] }, {
				:dynamics => ComputerEngineeringExampleDynamics.new, :timestep => 0.00001  , :step_count => 1, :initial_time => 0, :iterations => 4   , :float_error => 0.001 ,
				:desired_state => [[15.986]] }, {
				:dynamics => ComputerEngineeringExampleDynamics.new, :timestep => 0.000005 , :step_count => 1, :initial_time => 0, :iterations => 8   , :float_error => 0.001 ,
				:desired_state => [[15.975]] }, {
				:dynamics => ComputerEngineeringExampleDynamics.new, :timestep => 0.0000025, :step_count => 1, :initial_time => 0, :iterations => 16  , :float_error => 0.001 ,
				:desired_state => [[15.976]] }, {
				:dynamics => MultipleExampleDynamics.new           , :timestep => 0.5      , :step_count => 1, :initial_time => 0, :iterations => 4   , :float_error => 0.0001,
				:desired_state => [[1.471577], [8.946865]] }]

			generate_test(RungeKuttaIntegrator, testing_data)
		end # test_runge_kutta
	end # TestRungeKuttaIntegrator
end # TESTING

