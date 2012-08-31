require 'integrator_interface'

#--
# LATER support for higher order Euler
class EulerIntegrator < IntegratorInterface

	def initialize(options)
		@timestep     = options[:timestep    ] || (raise ArgumentError)
		@step_count   = options[:step_count  ] || 1
		@initial_time = options[:initial_time] || 0.0
	end

	def init(dynamics)
		@dynamics = dynamics
		@time     = @initial_time
	end

#	require 'pp'

	def next_state(state)
		range = state[0].size
		tau   = @timestep / @step_count

#		pp state

		t0  = @time
		s0  = state
		@step_count.times do |i|
			a   = @dynamics.step_acceleration(@time, state)
			s1 = s0.collect.with_index{ |s, i| s + [a[i]] }

			s0 = s1.collect{ |s| Array.new(range){ |i| s[i] + s[i + 1] * tau } }

			t0 += tau
		end

		@time = t0

		s0
	end
end # EulerIntegrator

if $0 == __FILE__ || (defined?($TESTING) && $TESTING)

	require 'integrator_test_case'
	require 'test/unit'
	require 'dynamics_interface'

#	http://tutorial.math.lamar.edu/Classes/DE/EulersMethod.aspx
	class LamarExampleDynamics < DynamicsInterface
		def initial_state              ; [[1.0]]                                         end # initial state
		def step_acceleration(t, state); [2.0 - Math::exp(-4.0 * t) - 2.0 * state[0][0]] end # acceleration
	end # LamarExampleDynamics

#	http://en.wikipedia.org/wiki/Euler_method
	class WikipediaExampleDynamics < DynamicsInterface
		def initial_state              ; [[1.0]]       end # initial state
		def step_acceleration(t, state); [state[0][0]] end # acceleration
	end # WikipediaExampleDynamics

	class TestEulerIntegrator < IntegratorTestCase
		# test Euler
		def test_euler
			testing_data = [{
				:dynamics => WikipediaExampleDynamics.new, :timestep => 1, :step_count => 1, :initial_time => 0, :iterations => 1, :float_error => 1e-15,
				:desired_state => [[2.0]] }, {
				:dynamics => WikipediaExampleDynamics.new, :timestep => 1, :step_count => 1, :initial_time => 0, :iterations => 2, :float_error => 1e-15,
				:desired_state => [[4.0]] }, {
				:dynamics => WikipediaExampleDynamics.new, :timestep => 1, :step_count => 1, :initial_time => 0, :iterations => 3, :float_error => 1e-15,
				:desired_state => [[8.0]] }, {
				:dynamics => LamarExampleDynamics.new    , :timestep => 0.1, :step_count => 1, :initial_time => 0, :iterations => 1, :float_error => 1e-9,
				:desired_state => [[0.9]] }, {
				:dynamics => LamarExampleDynamics.new    , :timestep => 0.1, :step_count => 1, :initial_time => 0, :iterations => 2, :float_error => 1e-9,
				:desired_state => [[0.852967995]] }, {
				:dynamics => LamarExampleDynamics.new    , :timestep => 0.1, :step_count => 1, :initial_time => 0, :iterations => 3, :float_error => 1e-9,
				:desired_state => [[0.837441500]] }, {
				:dynamics => LamarExampleDynamics.new    , :timestep => 0.1, :step_count => 1, :initial_time => 0, :iterations => 4, :float_error => 1e-9,
				:desired_state => [[0.839833779]] }, {
				:dynamics => LamarExampleDynamics.new    , :timestep => 0.1, :step_count => 1, :initial_time => 0, :iterations => 5, :float_error => 1e-9,
				:desired_state => [[0.851677371]]
			}]

			generate_test(EulerIntegrator, testing_data)
		end
	end # TestEulerIntegrator
end # TESTING

