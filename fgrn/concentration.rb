require 'fgrn/fgrn'

# concentration
class Fgrn::Concentration
	SATURATION              = 200.0
	ZERO_DELTA              = SATURATION * 0.000_000_1

	def self.decay(concentration, persistence_coeff, minimum_diffusion)
		[concentration *  persistence_coeff - minimum_diffusion, 0.0].max
	end
end # Fgrn::Concentration

