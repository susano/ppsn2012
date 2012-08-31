require 'imro/imro'

class Imro::Protein

	attr_reader \
		:value,
		:levels,
		:life
	
	# ctor
	def initialize(options)
		@value  = options[:value   ] || (raise ArgumentError)
		@levels = options[:levels  ] || (raise ArgumentError)
		@life   = options[:lifespan] || (raise ArgumentError)
	end

	# age this protein
	def age!
		@life = [@life - 1, 0].max
	end

	# dead ?
	def dead?
		@life == 0
	end

	# to_s
	def to_s
		"|#{@levels.collect{ |l| l.to_s.rjust(4) }.join('|')}| - #{@lifespan.to_s.rjust(2)} #{('%.2f' % @value).rjust(5)}"
	end
end # Imro::Protein

