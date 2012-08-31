require 'dynamics/dynamics_interface'

require 'utils/assert'

# from wieland1990controls_unstable_system
class JointedPoleBalancingDynamics < DynamicsInterface
	include Math

	CART_MASS          = 1.0
	CART_FORCE         = 10.0
	GRAVITY            = -9.8
	FRICTION_COEF_CART = 0.0005
	FRICTION_COEF_POLE = 0.000002
	POLES              = [
		{ :length => 1.0, :mass => 0.1  },
		{ :length => 0.1, :mass => 0.01 }]


	def initialize()
	end

	# initial state
	def initial_state
		state = Array.new(4){ [0.0, 0.0] }
	end

#	# from https://engineering.purdue.edu/~zak/ECE_675/Publish/modeling.html
#	def step_acceleration(time, state)
#
#		# cart position x
#		x  = state[0][0]
#		xp = state[0][1]
#
#		# pole 1 is the bottom one
#		l1 = POLES[0][:length] / 2.0
#		m1 = POLES[0][:mass  ]
#		t1  = state[1][0]
#		t1p = state[1][1]
#
#		# pole 2 is the top one
#		l2 = POLES[1][:length] / 2.0
#		m2 = POLES[1][:mass  ]
#		t2  = state[2][0]
#		t2p = state[2][1]
#
#		# constants
#		f   = state[1][0] * CART_FORCE
#		m   = CART_MASS
#		g   = GRAVITY
#		b   = FRICTION_COEF_CART
#		b1 = b2 = FRICTION_COEF_POLE
#
#
#
#		# xpp
#		xpp = (1.0 / m) * (f - n1 - b * xp)
#
#		NOT DONE
#	end

	# on acceleration step (from Wieland 1990 "Evolving Controls for Unstable Systems")
	# likely very wrong...
	def step_acceleration(time, state)

		# cart position x
		x  = state[0][0]
		xp = state[0][1]

		# (poles 'a' and 'b' are inversed in the paper's figure)
		# pole 'a' is the bottom one (first)
		la = POLES[0][:length]
		ma = POLES[0][:mass  ]
		ta  = state[1][0]
		tap = state[1][1]

		# pole 'b' is the top one (second)
		lb = POLES[1][:length]
		mb = POLES[1][:mass  ]
		tb  = state[2][0]
		tbp = state[2][1]

		# constants
		f   = state[1][0] * CART_FORCE
		g   = GRAVITY
		m   = CART_MASS
		muc = FRICTION_COEF_CART
		mua = mub = FRICTION_COEF_POLE

		# vbx
		vbx = xp + 2.0 * la * tap * cos(ta)

		# vby
		vby = 2.0 * la * tap * sin(ta)

		# xnum
		xnum = (f - muc * sign(xp)) * (8.0 * ma - 6.0 * mb * (4.0 - 3.0 * cos(ta - tb) ** 2.0)) +
			(3.0 / 2.0) * ((ma + 2.0 * mb) * (2.0 * ma + mb) * sin(2.0 * ta) -
				ma * mb * sin(2.0 * tb)) * g -
			6.0 * (mua * tap / la) * (ma + 2.0 * mb) * cos(ta) -
			6.0 * (mub * tbp / lb) * (ma + 3.0 * mb) * cos(tb) +
			9.0 * (mub * tbp / lb) * (ma + 2.0 * mb) * cos(ta) * cos(ta - tb) +
			9.0 * (mua * tap / la) * mb * cos(tb) * cos(ta - tb) -
			6.0 * mb * lb * (tbp ** 2.0) * (2.0 * ma + mb) * cos(ta) * sin(ta - tb) +
			6.0 * ma * mb * vby * tap * (cos(tb) ** 2.0) +
			3.0 * ma * mb * tbp * (xp - vbx) * sin(2.0 * tb) +
			(9.0 * ma * mb / (4.0 * la)) * (2.0 * vby * (vbx - xp) * sin(ta) * sin(tb) -
				(vby ** 2.0 + 2.0 * (xp - vbx) ** 2.0) * sin(ta - tb)) * cos(tb) -
			(9.0 * ma * mb / (4.0 * la)) * (vby ** 2.0) * sin(tb) * cos(ta + tb) -
			4.0 * ma * (ma + 2.0 * mb) * vby * tap -
			(3.0 * mb / (4.0 * la)) * (((xp - vbx) ** 2.0) * (2.0 * ma + 4.0 * mb) +
				(vby ** 2.0) * (5.0 * ma + 4.0 *  mb)) * sin(ta) -
			2.0 * mb * lb * (tbp ** 2.0) * (4.0 * ma + 3.0 * mb) * sin(tb)

		# xden
		xden = -3.0 * ma * mb * (cos(tb) ** 2.0) +
			3.0 * (ma + 2.0 * mb) * (2.0 * ma + mb) * (cos(ta) ** 2.0) +
			9.0 * mb * (2.0 * m * cos(ta - tb) ** 2.0 -
				ma * sin(ta - tb) ** 2.0) -
			8.0 * (ma + 3.0 * mb) * m -
			8.0 * (ma + mb) * (ma + 3.0 * mb / 4.0)

		# equation (15)
		xpp = xnum / xden


		# tnum
		tnum = g * ((ma + mb / 2.0) * sin(ta) +
				(3.0 / 2.0) * mb * cos(tb) * sin(ta - tb)) -
			xpp * (ma + 2.0 * mb) * cos(ta) +
			(3.0 * mb * vby / (4.0 * la)) * (xp - vbx) * (2.0 * cos(tb) ** 2.0 - 1.0) +
			(3.0 * mb / (4.0 * la)) * ((xp - vbx) ** 2.0 - vby ** 2.0) * sin(tb) * cos(tb) +
			(3.0 / 2.0) * (mb * xpp * cos(tb) + mub * tbp / lb) * cos(ta - tb) -
			2.0 * mb * lb * tbp * sin(ta - tb) -
			mua * tap / la

		# equation (14)
		tapp = tnum / (la * ((4.0 / 3.0) * ma + mb * (1.0 + 3.0 * sin(ta - tb) ** 2.0)))

		# equation (13)
		tbpp = (3.0 / (4.0 * lb)) * ((g + tap * (xp - vbx)) * sin(tb) +
				(vby * tap - xpp) * cos(tb) -
				mub * tbp / (mb * lb) -
				2.0 * la * tapp * cos(ta - tb))


		# acceleration
		[xpp, tapp, tbpp, 0.0]
	end

private
	def sign(x)
			x >= 0.0 ? 1.0 : -1.0
	end
end # JointedPoleBalancingDynamics

