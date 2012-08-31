import 'fgrn.VectorProtein'


class LandscapeProteinFactory

	# new landscape protein
	def self.new_landscape_protein(
		protein_length:int,
		peak1_position:int, peak1_value:int,
		peak2_position:int, peak2_value:int,
		black_position:int, black_size:int)

		# check arguments
		raise IllegalArgumentException if peak1_position < 0
		raise IllegalArgumentException if peak2_position < 0
		raise IllegalArgumentException if peak1_position >= protein_length
		raise IllegalArgumentException if peak2_position >= protein_length

		# data init
		data = int[protein_length]

		# peak distance
		peak_distance =
			(peak1_position < peak2_position) ?
				peak2_position - peak1_position :
				protein_length - (peak1_position - peak2_position)

		# first leg
		data[peak1_position] = peak1_value
		position = (peak1_position + 1) % protein_length
		distance = 1
		while(position != peak2_position)
			data[position] = peak1_value + int(double((peak2_value - peak1_value) * distance) / peak_distance)
			distance += 1
			position = (position + 1) % protein_length
		end

		# second leg
		if peak2_position != peak1_position
			peak_distance = protein_length - peak_distance
			data[peak2_position] = peak2_value
			position = (peak2_position + 1) % protein_length
			distance = 1
			while(position != peak1_position)
				data[position] = peak2_value + int(double((peak1_value - peak2_value) * distance) / peak_distance)
				distance += 1
				position = (position + 1) % protein_length
			end
		end

		# black
		if black_size != 0
			start = black_position - (black_size / 2)
			black_size.times do |i|
#				puts "MDEBUG start #{start}, i #{i}, protein_length #{protein_length}, (start + i) % protein_length #{(start + i) % protein_length}"
				data[(start + i + protein_length) % protein_length] = 0 # '+ protein_length' to avoid java's negative modulos...
			end
		end

		VectorProtein.new(data, true, nil)
	end
end 

