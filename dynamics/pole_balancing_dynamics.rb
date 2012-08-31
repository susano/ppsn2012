require 'dynamics/dynamics_interface'

require 'utils/assert'

class PoleBalancingDynamics < DynamicsInterface

	CART_MASS          = 1.0
	CART_FORCE         = 10.0
	GRAVITY            = -9.8
	FRICTION_COEF_CART = 0.0005
	FRICTION_COEF_POLE = 0.000002
#	FRICTION_COEF_CART = 0.0

	# +poles+ is a list of hashes, each of which must
	# have the keys: :mass, :length.
	def initialize(poles)
		@poles       = poles
		@input_index = 1 + poles.size
	end
#
#	require 'pp'

	# initial state
	def initial_state
		state = [[0.0, 0.0]]                                         # x
		@poles.each.with_index{ |p, i| state << [p[:initial], 0.0] } # poles
		state << [0.0, 0.0]                                          # input

#		pp state
	end

	# on acceleration step
	def step_acceleration(time, state)
		acceleration = Array.new(state.size, 0.0)

		# effective pole masses
		mes = Array.new(@poles.size){ |i|
			t = state[i + 1][0]

			@poles[i][:mass] * (1.0 - (3.0 / 4.0) * (Math::cos(t) ** 2.0))
		}

		# effective pole forces
		fis = Array.new(@poles.size){ |i|
			t    = state[i + 1][0]
			tp   = state[i + 1][1]
			mass = @poles[i][:mass  ]
			hl   = @poles[i][:length] / 2.0

			mass * hl * (tp * tp) * Math::sin(t) + (3.0 / 4.0) * mass * Math::cos(t) * ((FRICTION_COEF_POLE * tp) / (mass * hl) + GRAVITY * Math::sin(t))
		}

		# x''
		xp = state[0][1]
		f  = state[@input_index][0] * CART_FORCE

		xpp = (f - FRICTION_COEF_CART * (xp <=> 0.0) + fis.inject(0.0, &:+)) / (CART_MASS + mes.inject(0.0, &:+))
		acceleration[0] = xpp

		# t'' for each pole
		@poles.size.times do |i|
			t, tp = state[i + 1]
			mass  = @poles[i][:mass  ]
			hl    = @poles[i][:length] / 2.0

			acceleration[i + 1] = -(3.0 / (4.0 * hl)) * (xpp * Math::cos(t) + GRAVITY * Math::sin(t) + (FRICTION_COEF_POLE * tp) / (mass * hl))
		end

#		$stderr << "debug dynamics details: fi1 #{fis[0]}, fi2 #{fis[1]}, mi1 #{mes[0]}, mi2 #{mes[1]}\n"
#		pp acceleration

		acceleration
	end
end # PoleBalancingDynamics

