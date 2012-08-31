
class MondrianPortion

	# data
	def data:int[]
		@data
	end

	# ctor
	def initialize(side:int, direction:int, position:int, value1:int, value2:int, black_position:int)
		protein_length = side * side

		@side = side
		@data = int[protein_length]

		if direction == 0 # vertical split
			draw_rectangle(       0, 0,        position, side, value1) # value 1
			draw_rectangle(position, 0, side - position, side, value2) # value 2

			# black bar
			if black_position <= side # top-down
				draw_rectangle(0, 0, side, black_position, 0)
			else                      # bottom-up
				raise IllegalArgumentException if black_position > 29
				p = black_position - side
				draw_rectangle(0, p, side, side - p, 0)
			end
		else # horizontal split
			raise IllegalArgumentException if direction != 1

			draw_rectangle(0,        0, side,        position, value1) # value1
			draw_rectangle(0, position, side, side - position, value2) # value2

			# black bar
			if black_position <= side # left-starting
				draw_rectangle(0, 0, black_position, side, 0)
			else                      # right-starting
				raise IllegalArgumentException if black_position > 29
				p = black_position - side
				draw_rectangle(p, 0, side - p , side, 0)
			end
		end
	end

private
	# draw a filled rectangle on the @data
	def draw_rectangle(x:int, y:int, width:int, height:int, color:int):void
		side = @side
		width.times do |i|
			height.times do |j|
				@data[(y + j) * side + (x + i)] = color
			end
		end
	end
end # MondrianPortion

