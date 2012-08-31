
class ProteinConcentration

	# ctor
	def initialize(size:int, scalar:double, bitmap:double[])
		@size   = size
		@scalar = scalar
		@bitmap = bitmap
	end

	# clone
	def make_clone():ProteinConcentration
		bitmap = nil
		if @bitmap != nil
			bitmap = double[@size]
			@size.times do |i|
				bitmap[i] = @bitmap[i]
			end
		end

		ProteinConcentration.new(@size, @scalar, bitmap)
	end

	# fill with one value
	def fill(c:double)
		@scalar = c
		@bitmap = nil
	end

	def []=(index:int, c:double)
		if !@bitmap
			# new array
			bitmap = double[@size]
			@size.times do |i|
				bitmap[i] = @scalar
			end
			@bitmap = bitmap
		end

		@bitmap[index] = c
	end
	
	def [](index:int)
		@bitmap ? @bitmap[index] : @scalar
	end
end # ProteinConcentration

