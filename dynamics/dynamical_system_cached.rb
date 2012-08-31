require 'dynamics/dynamical_system'

class DynamicalSystemCached
	attr_reader :inputs, :evaluations

	# A node in the tree of cached states
	class CachedState
		attr_reader :state
		attr_accessor \
			:cache_minus,
			:cache_zero,
			:cache_plus

		# ctor
		def initialize(state)
			@state = state.collect{ |s| s.clone }

			@cache_minus = nil
			@cache_zero  = nil
			@cache_plus  = nil
		end
	end # CachedState

	# ctor
	def initialize(options)
		dynamics       = options[:dynamics     ] || (raise ArgumentError)
		integrator     = options[:integrator   ] || (raise ArgumentError)
		@input_mapping = options[:input_mapping] || (raise ArgumentError)
		assert{ @input_mapping.size == 1 } # only works with one bang-zero-bang input ATM

		# init dynamical system
		@system = DynamicalSystem.new(
			:dynamics      => dynamics,
			:integrator    => integrator,
			:input_mapping => @input_mapping)

		@inputs = Array.new(@input_mapping.size) # inputs
		@cache  = CachedState.new(@system.state) # cache
		@learning = false
		@evaluations = 0
		@current_cache = @cache
	end

	# reset
	def reset
		@system.reset
		@current_cache = @cache
		@learning = false
	end

	# current state
	def state
		@current_cache.state
	end

	# update
	def update
		i = @inputs[0]
		if @learning
			@system.inputs[0] = i
			@system.update
		
			cached_state = CachedState.new(@system.state)
			if    i == -1.0 then @current_cache.cache_minus = cached_state
			elsif i ==  0.0 then @current_cache.cache_zero  = cached_state
			elsif i ==  1.0 then @current_cache.cache_plus  = cached_state
			else raise RuntimeError end

			@current_cache = cached_state
		else
			# running in cached mode

			next_cache = 
				if    i == -1.0 then @current_cache.cache_minus
				elsif i ==  0.0 then @current_cache.cache_zero
				elsif i ==  1.0 then @current_cache.cache_plus
				else raise RuntimeError end

			if next_cache.nil?
				@evaluations += 1
				@learning = true
				@system.state = @current_cache.state.collect{ |s| s.clone }
				update  # call self back in learning mode
			else
				@current_cache = next_cache
			end
		end
	end
end # DynamicalSystemCached


if $0 == __FILE__ || defined? $TESTING
	require 'test/unit'
	require 'dynamics/acrobot_dynamics'
	require 'dynamics/dynamical_system'
	require 'dynamics/runge_kutta_integrator'

#	require 'pp'

	class DynamicalSystemCachedTest < Test::Unit::TestCase
		def test_general
			timestep   = 0.05
			step_count = 2

			# system
			system = DynamicalSystem.new(
				:dynamics      => AcrobotDynamics.new,
				:integrator    => RungeKuttaIntegrator.new(
					:timestep   => timestep,
					:step_count => step_count),
				:input_mapping => [[2, 0]]
			)

			# cached system
			cached_system = DynamicalSystemCached.new(
				:dynamics      => AcrobotDynamics.new,
				:integrator    => RungeKuttaIntegrator.new(
					:timestep   => timestep,
					:step_count => step_count),
				:input_mapping => [[2, 0]]
			)

			# actions
			action_strings = [
				'+------------------++++++++++--+++++++++++++---------++++----------------++++++-----+++++++++++---------++---------------++++++++++++++++++++++++------------------------------+++++++++++++++++++++++++++++.-----------------------------+++++------------------------+-------+++++++++++++++++++++++++++++++++',
				'+-----------..---++++++++++--+++++++++++++---------++++----------------++++++-----+++++++++++---------++---------------++++++++++++++++++++++++------------------------------+++++++++++++++++++++++++++++.-----------------------------+++++------------------------+-------+++++++++++++++++++++++++++++++++',
				'------------------------------------------',
				'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++']

			action_lists = action_strings.collect do |as|
				Array.new(as.size) do |i|
					case(as[i])
					when '-'; -1.0
					when '.';  0.0
					when '+';  1.0
					else raise ArgumentError end
				end
			end

			eval_count = 4


			eval_count.times do |e|
#				$stderr << "debug evaluation #{e}\n"
				action_lists.each do |actions|
#					$stderr << "debug - begin action list\n"
					actions.each do |act|
#						$stderr << "debug - one action\n"

						state        = system.state
						cached_state = cached_system.state
#						pp state
#						pp cached_state

						assert_equal(cached_state.size, state.size)
						state.size.times do |i|
							a  = state[i]
							ca = cached_state[i]
							assert_equal(a.size, ca.size)
							a.size.times{ |j| assert_equal(a[j], ca[j]) }
						end

						system.inputs[0]        = act
						cached_system.inputs[0] = act

						system.update
						cached_system.update
					end
					system.reset
					cached_system.reset
				end
			end
		end
	end # DynamicalSystemCachedTest
end # TESTING


