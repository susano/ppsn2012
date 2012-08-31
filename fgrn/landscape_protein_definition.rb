require 'fgrn/fgrn'
require 'fgrn/protein_definition'
require 'utils/numeric_bind'

require 'java'
java_import 'fgrn.LandscapeProteinFactory'

# landscape protein definition
class Fgrn::LandscapeProteinDefinition < Fgrn::ProteinDefinition

	attr_reader \
		:peak1_position, :peak1_value,
		:peak2_position, :peak2_value,
		:black_position, :black_size

	# new random
	def self.new_random(options)
		protein_length        = options[:protein_length       ] || (raise ArgumentError)
		max_value             = options[:max_value            ] || (raise ArgumentError)
		crossover             = options[:crossover            ] || (raise ArgumentError)
		max_black_coefficient = options[:max_black_coefficient] || (raise ArgumentError)

		self.new(
			protein_length,
			max_value,
			crossover,
			rand(protein_length), rand(max_value),
			rand(protein_length), rand(max_value),
			rand(protein_length), rand((protein_length * max_black_coefficient).floor))
	end

	# from hash
	def self.from_hash(hash)
		self.new(
			hash[:protein_length] || (raise ArgumentError),
			hash[:max_value     ] || (raise ArgumentError),
			hash[:crossover     ] || (raise ArgumentError),
			hash[:peak1_position] || (raise ArgumentError), hash[:peak1_value] || (raise ArgumentError),
			hash[:peak2_position] || (raise ArgumentError), hash[:peak2_value] || (raise ArgumentError),
			hash[:black_position] || (raise ArgumentError), hash[:black_size ] || (raise ArgumentError))
	end

	# ctor
	def initialize(
		protein_length,
		max_value,
		crossover,
		peak1_position, peak1_value,
		peak2_position, peak2_value,
		black_position, black_size) 

		@protein_length = protein_length
		@max_value      = max_value
		@crossover      = crossover
		@peak1_position = peak1_position; @peak1_value = peak1_value
		@peak2_position = peak2_position; @peak2_value = peak2_value
		@black_position = black_position; @black_size  = black_size
	end

	# clone
	def clone
		Fgrn::LandscapeProteinDefinition.new(
			@protein_length,
			@max_value,
			@crossover,
			@peak1_position, @peak1_value,
			@peak2_position, @peak2_value,
			@black_position, @black_size
		)
	end

	# mutate!
	def mutate!(mutation_rate)
		@peak1_position =  (@peak1_position + rand(@protein_length) - @protein_length / 2) % @protein_length    if rand < mutation_rate
		@peak1_value    = ((@peak1_value    + rand(@max_value)      - @max_value      / 2)).bind(0, @max_value) if rand < mutation_rate

		@peak2_position =  (@peak2_position + rand(@protein_length) - @protein_length / 2) % @protein_length    if rand < mutation_rate
		@peak2_value    = ((@peak2_value    + rand(@max_value)      - @max_value      / 2)).bind(0, @max_value) if rand < mutation_rate

		@black_position =  (@black_position + rand(@protein_length) - @protein_length / 2) % @protein_length    if rand <= mutation_rate
		@black_size     =  (@black_size     +(rand(@protein_length) - @protein_length / 2) / 2).bind(0, @protein_length) if rand <= mutation_rate
	end

	# crossover
	def crossover(definition)
		case(@crossover)
		when :parameter_swap
			Fgrn::LandscapeProteinDefinition.new(
				@protein_length,
				@max_value,
				@crossover,
				[@peak1_position, definition.peak1_position][rand(2)],
				[@peak1_value,    definition.peak1_value]   [rand(2)],
				[@peak2_position, definition.peak2_position][rand(2)],
				[@peak2_value,    definition.peak2_value]   [rand(2)],
				[@black_position, definition.black_position][rand(2)],
				[@black_size,     definition.black_size]    [rand(2)])
		when :parameter_mix
			raise ArgumentError, "Unimplemented crossover type!"
		else
			raise ArgumentError, "Unknown crossover type!"
		end
	end

	# new protein
	def new_protein
		LandscapeProteinFactory.new_landscape_protein(
			@protein_length,
			@peak1_position, @peak1_value,
			@peak2_position, @peak2_value,
			@black_position, @black_size)
	end

	# to s
	def to_s
		"L:#{@protein_length} P1(#{@peak1_position.to_s.rjust(3)},#{@peak1_value.to_s.rjust(3)}) P2(#{@peak2_position.to_s.rjust(3)},#{@peak2_value.to_s.rjust(3)}) B(#{@black_position.to_s.rjust(3)},#{@black_size.to_s.rjust(3)})"
	end

	# to hash
	def to_hash
		{
			:protein_length => @protein_length,
			:max_value      => @max_value,
			:crossover      => @crossover,
			:peak1_position => @peak1_position, :peak1_value => @peak1_value,
			:peak2_position => @peak2_position, :peak2_value => @peak2_value,
			:black_position => @black_position, :black_size  => @black_size
		}
	end
end # LandscapeProteinDefinition

