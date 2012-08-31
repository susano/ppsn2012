require 'fgrn/fgrn'

class Fgrn::ProteinDefinition

	# from hash
	def self.from_hash(hash)
		case(hash[:name])

		when :fractal  ; Fgrn::FractalProteinDefinition.from_hash(hash)
		when :mondrian ; Fgrn::MondrianProteinDefinition.from_hash(hash)
		when :landscape; Fgrn::LandscapeProteinDefinition.from_hash(hash)
		else raise ArgumentError, "Unknown protein definition type '#{hash[:name]}'"
		end
	end

	def new_protein           ; raise NotImplementedError; end
	def clone                 ; raise NotImplementedError; end
	def mutate!(mutation_rate); raise NotImplementedError; end
	def crossover(definition) ; raise NotImplementedError; end
	def to_s                  ; raise NotImplementedError; end
	def to_hash               ; raise NotImplementedError; end
end # Fgrn::ProteinDefinition

require 'fractal_protein_definition'
require 'mondrian_protein_definition'
require 'landscape_protein_definition'

