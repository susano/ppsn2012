require 'dynamics/acrobot_dynamics'
require 'dynamics/dynamical_system'
require 'dynamics/runge_kutta_integrator'

# actions
#actions_string = '-------------------------------------...+++++++++++++++++.........---------------------------..+++++++++++++++++++.......----------------------------..........................------------+++++++++++++..........................---------------------+++++++++++++++++++++++.........-----------------------------...........................---------.+++++++++++++++++++++++++++++'

#actions_string = '+------------------++++++++++--+++++++++++++---------++++----------------++++++-----+++++++++++---------++---------------++++++++++++++++++++++++------------------------------+++++++++++++++++++++++++++++.-----------------------------+++++------------------------+-------+++++++++++++++++++++++++++++++++'

actions_string_270 = '+++++++++++++++++++++++++++++++---------------------------+++++++++++++++++++++++++++---------------------------+++++++++++++++------------------------------+++++++++++++++++-----------------------------------------------.+++++++++++++------------------------------------'

#actions_string_270_a = '+++++++++++++++++++++++++++++++---------------------------+++++++++++++++++++++++++++---------------------------+++++++++++++++---------'
#actions_string_270_b = '---------------------+++++++++++++++++-----------------------------------------------.+++++++++++++------------------------------------'

#actions_string = actions_string_270_a
actions_string = actions_string_270

#actions_string += actions_string[-1] * 100
actions_string += '-' * 1

#actions_string = (('-' * 30) + ('+' * 15)) * 10

timestep   = 0.05
step_count = 2


actions = Array.new(actions_string.size) do |i|
	case(actions_string[i])
	when '-'; -1.0
	when '.';  0.0
	when '+';  1.0
	else raise ArgumentError end
end

# dynamics
dynamics = AcrobotDynamics.new

# integrator
integrator = RungeKuttaIntegrator.new(
	:timestep   => timestep,
	:step_count => step_count)

# system
system = DynamicalSystem.new(
	:dynamics      => dynamics,
	:integrator    => integrator,
	:input_mapping => [[2, 0]]
)

# generate data
data = actions.collect do |a|
	theta1 = system.state[0][0]
	theta2 = system.state[1][0]

	system.inputs[0] = a
	system.update

	{
		:theta1 => theta1,
		:theta2 => theta2,
		:action => a
	}
end

def plot(data, output_filename)
#	image_width  = 2048
#	image_height = 600
#	image_width  = 1024
#	image_height = 300
	image_width  = 1536
#	image_height = 450
	image_height = 400


	# first plot
#	data_index_first = 0
#	data_index_size  = 135
#	x_range_extra    = 0
#	mask = Array.new(data.size, true)
#	x_scale = 6.0
#	extra_lines = 6
#	actions_removed = 0

	# second plot
	data_index_first = 135
	data_index_size  = data.size - data_index_first
	mask = Array.new(data.size, true)
	x_range_extra = 4
	x_scale = 6.0
	extra_lines = 0
	actions_removed = 1

	size = data.size
#	size = 500
  command = %Q{
		cat << EOP | gnuplot
##	set terminal png size 2048,480 font "arial" 14
		set terminal png size #{image_width}, #{image_height} font "arial" 18
		set output '#{output_filename}'
		## set autoscale x
		## set autoscale y
##		LX = 0.032
		LX = 0.050
		RX = 0.0001
		BY = 0.128
##		BY = 0.
		TY = 0.002
		##X  = 0.9679
		X  = 0.95
##		Y1 = 0.3
##		Y2 = 0.573
		Y1 = 0.2
		Y2 = 0.673
		set size LX + X + RX, BY + Y1 + Y2 + TY
		set bmargin BY
		set tmargin TY
		set lmargin LX
		set rmargin RX
		set multiplot
		## -- bottom: activation plot
		set size X, Y1
		set origin LX, BY
		set xtics 0, 50 nomirror
		set mxtics 50
		set ytics -1.0, 1.0
		set tmargin 0
		##set ticscale 2 1
		##set xlabel 'Timesteps'  offset -9.0,1.0
		set xlabel 'Timesteps'  offset 4.0,1.0
		##set ylabel 'Torque(Nm)' offset -0.5
		set ylabel 'Torque (Nm)' offset 0.5
##		set xrange [-1:#{size}]
		set xrange [#{data_index_first -1}:#{data_index_first + data_index_size + x_range_extra}]
		set yrange [-1.5:1.5]
		set arrow 10 from -1.0,0 to #{size + x_range_extra},0 nohead ls 0
		plot '-' using 1:2  notitle w steps lw 2 lc rgb 'black'
		#{data[data_index_first, data_index_size - actions_removed].collect.with_index{ |h, i| "#{i + data_index_first} #{h[:action]}" }.join("\n")}
		e
		## -- top: acrobot
		set size X, Y2
		set origin LX, BY + Y1
		unset xlabel
		unset xtics
		set bmargin 0
		set ytics -2.0, 1.0
		set ylabel 'Height (m)'
		set yrange [-2.5:2.5]
##		set yrange [-2.5:1.5]
##		set xrange [-1:#{size}]
		set xrange [#{data_index_first -1}:#{data_index_first + data_index_size + x_range_extra}]
		##set arrow 10 from -1,-1.0 to #{size + x_range_extra},-1.0 nohead ls 0
		set arrow 10 from -1,1.0 to #{size + x_range_extra},1.0 nohead ls 0 lw 1
		#{
		x_tip_previous = -1.0
		data[data_index_first, data_index_size + extra_lines].collect.with_index do |h, i|
			action = h[:action]
			theta1 = h[:theta1]
			theta2 = h[:theta2]

			x_origin = (i + data_index_first).to_f
			y_origin = 0.0

			x_joint = x_origin + x_scale * Math::sin(theta1)
			y_joint = y_origin - Math::cos(theta1)

			x_tip = x_joint + x_scale * Math::sin(theta1 + theta2)
			y_tip = y_joint - Math::cos(theta1 + theta2)

			bot_color = 'black'

			output = 
				if (mask[i])
#				if (
#					(i % 3 == 0) &&
#					(x_tip >= x_tip_previous))
					%Q{
						plot '-' using 1:2 notitle w l lw 1 lc rgb 'black'
						#{x_origin} #{y_origin}
						#{x_joint } #{y_joint }
						#{x_tip   } #{y_tip   }
						e

						plot '-' using 1:2 notitle w points pt 5 ps 0.4 lc rgb 'red'
						#{x_origin} #{y_origin}
						#{x_joint } #{y_joint }
						e
					}
				else '' end

			x_tip_previous = x_tip
			output
		end.join("\n")}
		unset multiplot
		EOP
	}.gsub("\t", '')
	puts command
  system(command)
end

plot(data, 'acrobot.png')

###{i != 0 ? 're' : ''}
				##replot '-' using 1:2 notitle w p
				###{x_origin}, #{y_origin}
				###{x_joint }, #{y_joint }
				##e
