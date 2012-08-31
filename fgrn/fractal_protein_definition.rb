require 'fgrn/fgrn'
require 'fgrn/protein_definition'
require 'fgrn/fractal_protein_factory'

# fractal protein definition
class Fgrn::FractalProteinDefinition < Fgrn::ProteinDefinition

	attr_accessor :x, :y, :z

	GENERATION_RANGES = [
		(-2.0)..(1.0),
		(-1.0)..(1.0),
		(-2.0)..(2.0)]

	# preevolved fractal proteins
	PREEVOLVED_PROTEINS = [
		[-0.738639485,  0.263344218, 0.950590533],
		[0.446195868,   0.075411237, 0.556855983],
		[0.029328288,  -0.559617908, 0.571611682],
		[0.372295297,  -0.393093661, 0.532761620],
		[0.115878780,  -0.599185156, 0.326792199],
		[0.315958129,   0.560350352, 1.319956053],
		[0.056062502,  -0.400830103, 0.802072207],
		[-0.334253975,  0.578844569, 0.505890072],
		[-0.036454360,  0.690664388, 0.516281625],
		[0.132541887,   0.698126164, 0.468306528]]

	# new random
	def self.new_random(options)
		random_coordinates = options[:random_coordinates] || false
		side               = options[:side              ] || (raise ArgumentError)
		crossover          = options[:crossover         ] || (raise ArgumentError)

		# coordinates
		coordinates = random_coordinates ?
			GENERATION_RANGES.collect{ |r| r.first + rand * (r.last - r.first) } :
			PREEVOLVED_PROTEINS[rand(PREEVOLVED_PROTEINS.size)].clone

		# result
		self.new(
			:side      => side,
			:crossover => crossover,
			:x         => coordinates[0],
			:y         => coordinates[1],
			:z         => coordinates[2]
		)
	end

	# from hash
	def self.from_hash(hash)
		self.new(
			:side      => hash[:side],
			:crossover => hash[:crossover],
			:x         => hash[:x],
			:y         => hash[:y],
			:z         => hash[:z])
	end

	# ctor
	def initialize(options)
		@side      = options[:side     ] || (raise ArgumentError)
		@crossover = options[:crossover] || (raise ArgumentError)
		@x         = options[:x]         || (raise ArgumentError)
		@y         = options[:y]         || (raise ArgumentError)
		@z         = options[:z]         || (raise ArgumentError)
	end

	# clone
	def clone
		Fgrn::FractalProteinDefinition.new(
			:side      => @side,
			:crossover => @crossover,
			:x         => @x,
			:y         => @y, 
			:z         => @z
		)
	end

	# mutate!
	def mutate!(mutation_rate)
		@x += rand - 0.5 if (rand <= mutation_rate)
		@y += rand - 0.5 if (rand <= mutation_rate)
		@z += rand - 0.5 if (rand <= mutation_rate)
	end

	# new crossover
	def crossover(definition)
		case(@crossover)
		when :none
			self.clone

		when :parameter_swap
			Fgrn::FractalProteinDefinition.new(
				:side      => @side,
				:crossover => @crossover,
				:x         => [@x, definition.x][rand(2)],
				:y         => [@y, definition.y][rand(2)],
				:z         => [@z, definition.z][rand(2)]
			)
		when :parameter_mix
			Fgrn::FractalProteinDefinition.new(
				:side      => @side,
				:crossover => @crossover,
				:x         => @x + rand * (definition.x - @x),
				:y         => @y + rand * (definition.y - @y),
				:z         => @z + rand * (definition.z - @z)
			)
		else
			raise "Unknown crossover type!"
		end
	end

	# new protein
	def new_protein
		Fgrn::FractalProteinFactory.from_definition(@side, @x, @y, @z)
	end

	# to_s
	def to_s
		"[#{'%.4f' % @x}, #{'%.4f' % @y}, #{'%.4f' % @z}]"
	end

	# to hash
	def to_hash
		{
			:name      => :fractal,
			:side      => @side,
			:crossover => @crossover,
			:x         => @x,
			:y         => @y,
			:z         => @z
		}
	end

#		# to lines
#		def to_lines
#	#		x = ([[0.0, (@x + 2.0) / 3.0].max, 1.0].min * 255).to_i
#			x = ([[0.0, (@x + 1.0) / 2.0].max, 1.0].min * 255).to_i
#			y = ([[0.0, (@y + 1.0) / 2.0].max, 1.0].min * 255).to_i
#			z = ([[0.0, (@z + 1.5) / 3.0].max, 1.0].min * 255).to_i
#
#			[28, [x, y, z]]
#		end
end # FractalProteinDefinition

