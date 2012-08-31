require 'fgrn/fgrn'
#require 'vector_protein'
require 'inline'
require 'mirah_inline'

require 'java'
java_import 'fgrn.ProteinConcentration'
java_import 'fgrn.VectorProtein'

class Fgrn::FractalProteinFactory 
#	@@cache = {}

	FRACTAL_ITERATION_MAX = 127

	# from definition
	def self.from_definition(side, x, y, z)
		coordinates = [x, y, z]

#		data = @@cache[coordinates]
#		if data.nil?
			data = generate_fractal_data(side, x, y, z)
#			@@cache[coordinates] = data
#		end

		VectorProtein.new_from_ruby(data)
	end

private
	def self.generate_fractal_data(side, x, y, z)
		data = Array.new(side * side, -1)

		side.times do |i|
			px = x - (z / 2.0) + i * z / (side - 1)
			side.times do |j|
				py = y - (z / 2.0) + j * z / (side - 1)
				data[j * side + i] = fractal_point(px, py)
			end
		end

		data
	end

	class << self

		# fractal point
		inline :Mirah do |builder|
			builder.mirah "
			def fractal_point(x:double, y:double):int
				nx = x
				ny = y
				i = 0
				while((nx * nx + ny * ny) < (2.0 * 2.0)  && i < #{FRACTAL_ITERATION_MAX})
					nx_tmp = nx * nx - ny * ny + x
					ny     = nx * ny * 2.0 + y
					nx     = nx_tmp

					i += 1
				end

				#{FRACTAL_ITERATION_MAX} - i
			end
			"
		end

	end

	# fractal point
#	def self.fractal_point(x, y)
#		nx = x
#		ny = y
#		i = 0
#		while((nx * nx + ny * ny) < (2.0 * 2.0)  && i < FRACTAL_ITERATION_MAX)
#			nx_tmp = nx * nx - ny * ny + x
#			ny     = nx * ny * 2.0 + y
#			nx     = nx_tmp
#
#			i += 1
#		end
#
#		FRACTAL_ITERATION_MAX - i
#	end
end # Fgrn::FractalProteinFactory

