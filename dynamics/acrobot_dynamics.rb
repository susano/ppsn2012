require 'dynamics/dynamics_interface'
require 'utils/assert'

# according to sutton1996rl_coarse_learning with the
# following changes
# - bang-bang control
#--
# FIX string state keys to symbols
class AcrobotDynamics < DynamicsInterface
	include Math # for convenience

	G         = 9.8 # gravity
	TORQUE    = 1.0 # torque
	M1  = M2  = 1.0 # masses
	L1  = L2  = 1.0 # lengths
	LC1 = LC2 = 0.5 # lengths to center of mass of links
	I1  = I2  = 1.0 # moments of inertia of links

	# angular velocity bounds
	T1P_MIN  = -4 * PI
	T1P_MAX  =  4 * PI
	T2P_MIN  = -9 * PI
	T2P_MAX  =  9 * PI 

	# initial state
	def initial_state
#		[
#			[0.0, 0.0],
#			[0.0, 0.0],
#			[0.0, 0.0]
#		]
		[
#			[PI , 0.0],
#			[PI + 0.01 , -0.001],
			[0.0, 0.0],
			[0.0, 0.0],
			[0.0, 0.0]
		]
	end # initial state

	# tip height
	def tip_height(state)
		t1 = state[0][0]
		t2 = state[1][0]

		L1 * -cos(t1) + L2 * -cos(t1 + t2)
	end

	# is balanced?
	def balanced?(state)
		t1 = state[0][0]
		t2 = state[1][0]
		-(L1 * cos(t1) + L2 * cos(t1 + t2)) > L1
	end

#	require 'pp'

	# compute one acceleration step
	def step_acceleration(time, state)
		
#		pp state

		t1, t1p = state[0]
		t2, t2p = state[1]
		f       = state[2][0]

		# modulo the positions
#		t1 = begin m = t1 % (2.0 * PI);  m > PI ? -(PI - m) : m end
#		t2 = begin m = t2 % (2.0 * PI);  m > PI ? -(PI - m) : m end

		# bind velocities
		t1p = (t1p < T1P_MIN) ? T1P_MIN : ((t1p > T1P_MAX) ? T1P_MAX : t1p)
		t2p = (t2p < T2P_MIN) ? T2P_MIN : ((t2p > T2P_MAX) ? T2P_MAX : t2p)

		# f
#		assert{ inputs.include?('F') }
#		f = inputs['F']
#		assert{ [0.0, -1.0, 1.0].include?(f) }
		
		# tau
		tau = f * TORQUE 

		# phi 2
		phi2 = M2 * LC2 * G * cos(t1 + t2 - PI / 2.0)

		# phi 1
		phi1 = -M2 * L1 * LC2 * (t2p ** 2.0) * sin(t2) - 2.0 * M2 * L1 * LC2 * t2p * t1p * sin(t2) + (M1 * LC1 + M2 * L1) * G * cos(t1 - PI / 2.0) + phi2

		# d2
		d2 = M2 * (LC2 ** 2.0 + L1 * LC2 * cos(t2)) + I2

		# d1
		d1 = M1 * (LC1 ** 2.0) + M2 * ((L1 ** 2.0) + (LC2 ** 2.0) + 2.0 * L1 * LC2 * cos(t2)) + I1 + I2

		# t2pp
		t2pp = (tau + (d2 / d1) * phi1 - phi2) / (M2 * (LC2 ** 2.0) + I2 - (d2 ** 2.0) / d1)

		# t1pp
		t1pp = (d2 * t2pp  + phi1) / -d1

#		$stderr << "debug acceleration t1pp #{t1pp}, t2pp #{t2pp}\n"
		mask = 1_000_000_000_000_000
		t1pp = (t1pp * mask).to_i / mask.to_f
		t2pp = (t2pp * mask).to_i / mask.to_f
#		t1pp = (t1pp * 10_000).to_i / 10_000.0
#		t2pp = (t2pp * 10_000).to_i / 10_000.0

	
		[t1pp, t2pp, 0.0]
	end # step_acceleration

	# compute energy of a given +state+
	def energy(state)

		t1, t1p = state[0]
		t2, t2p = state[1]

		t1 += 1.5 * PI

		k = 0.5 * M1 * (LC1 ** 2.0) * (t1p ** 2.0) + 0.5 * I1 * (t1p ** 2.0) + 0.5 * M2 * (L1 ** 2.0) * (t1p ** 2.0) +
			  0.5 * M2 * (LC2 ** 2.0) * ((t1p ** 2.0) + 2.0 * t1p * t2p + (t2p ** 2.0)) +
			M2 * L1 * LC2 * ((t1p ** 2.0)  + t1p * t2p) * cos(t2) +
			0.5 * I2 * ((t1p ** 2.0) + 2.0 * t1p * t2p + (t2p ** 2.0))

		u = M1 * G * LC1 * sin(t1) + M2 * G * L1 * sin(t1) + M2 * G * LC2 * sin(t1 + t2)
#		u = M1 * G * LC1 * sin(t1) + M2 * G * LC2 * sin(t1 + t2)

		$stderr << "debug energy k #{k}      u #{u}"

		k + u
	end # energy

	# post process
	def post_process(state)
		t1, t1p = state[0]
		t2, t2p = state[1]

		# t1, t2 modulo 2pi
		t1 = (t1 <=> 0.0) * (t1.abs % (2.0 * Math::PI))
		t2 = (t2 <=> 0.0) * (t2.abs % (2.0 * Math::PI))

		# t1, t2 to [-pi, pi]
		t1 = (t1 > Math::PI) ? t1 - Math::PI : ((t1 < -Math::PI) ? t1 + Math::PI : t1)
		t2 = (t2 > Math::PI) ? t2 - Math::PI : ((t2 < -Math::PI) ? t2 + Math::PI : t2)

		# t1p, t2p min/max
		t1p = (t1p < T1P_MIN) ? T1P_MIN : ((t1p > T1P_MAX) ? T1P_MAX : t1p)
		t2p = (t2p < T2P_MIN) ? T2P_MIN : ((t2p > T2P_MAX) ? T2P_MAX : t2p)

		s = state.collect{ |v| v.clone }

		s[0][0] = t1
		s[0][1] = t1p
		s[1][0] = t2
		s[1][1] = t2p

		s
	end
end # AcrobotDynamics

# crop state
#	def crop_state(state)
#	end

