require 'fgrn/fgrn'

# mondrian protein definition
class Fgrn::MondrianPortionDefinition
	attr_accessor \
		:direction,     # 0..1
		:position,      # 0..15
		:value1,        # 0..127
		:value2,        # 0..127
		:black_position # 0..29

	# new random
	def self.new_random(options)
		side      = options[:side     ] || (raise ArgumentError)
		crossover = options[:crossover] || (raise ArgumentError)

		self.new(
			:side           => side,
			:crossover      => crossover,
			:direction      => rand(2),
			:position       => rand(16),
			:value1         => rand(128),
			:value2         => rand(128),
			:black_position => rand(30)
		)
	end

	# from hash
	def self.from_hash(hash)
		self.new(
			:side           => hash[:side],
			:crossover      => hash[:crossover],
			:direction      => hash[:direction],
			:position       => hash[:position],
			:value1         => hash[:value1],
			:value2         => hash[:value2],
			:black_position => hash[:black_position])
	end

	# ctor
	def initialize(options)
		@side           = options[:side          ] || (raise ArgumentError)
		@crossover      = options[:crossover     ] || (raise ArgumentError)
		@direction      = options[:direction     ] || (raise ArgumentError)
		@position       = options[:position      ] || (raise ArgumentError)
		@value1         = options[:value1        ] || (raise ArgumentError)
		@value2         = options[:value2        ] || (raise ArgumentError)
		@black_position = options[:black_position] || (raise ArgumentError)
	end

	# clone
	def clone
		Fgrn::MondrianPortionDefinition.new(
			:side           => @side,
			:crossover      => @crossover,
			:direction      => @direction,
			:position       => @position,
			:value1         => @value1,
			:value2         => @value2,
			:black_position => @black_position)
	end

	# mutate!
	def mutate!(mutationRate)
		@direction ^= 1           if (rand <= mutationRate)
		@position  ^= 1           if (rand <= mutationRate)
		@value1 ^= (1 << rand(7)) if (rand <= mutationRate)
		@value2 ^= (1 << rand(7)) if (rand <= mutationRate)
		@black_position = (@black_position  + rand(30)) % 30 if (rand <= mutationRate)
	end

	# crossover
	def crossover(definition)
		case(@crossover)
		# none
		when :none
			self.clone

		# parameter swap
		when :parameter_swap
			Fgrn::MondrianPortionDefinition.new(
				:side           => @side,
				:crossover      => @crossover,
				:direction      => [@direction     , definition.direction     ][rand(2)],
				:position       => [@position      , definition.position      ][rand(2)],
				:value1         => [@value1        , definition.value1        ][rand(2)],
				:value2         => [@value2        , definition.value2        ][rand(2)],
				:black_position => [@black_position, definition.black_position][rand(2)])

		# parameter mix
		when :parameter_mix
			Fgrn::MondrianPortionDefinition.new(
				:side           => @side,
				:crossover      => @crossover,
				:direction      => (@direction      + rand * (definition.direction      - @direction     )).round,
				:position       => (@position       + rand * (definition.position       - @position      )).round,
				:value1         => (@value1         + rand * (definition.value1         - @value1        )).round,
				:value2         => (@value2         + rand * (definition.value2         - @value2        )).round,
				:black_position => (@black_position + rand * (definition.black_position - @black_position)).round
			)

		# component swap
		when :component_swap
			[self, definition][rand(2)].clone

		else raise ArgumentError, "Unknown crossover type '#{@crossover}'" end
	end

	# new protein
	def new_protein
		MondrianProteinFactory.new_mondrian_protein(@side, @direction, @position, @value1, @value2, @black_position)
	end

	# to string
	def to_s
		"[D:#{@direction} P:#{@position.to_s.rjust(2)} V:#{@value1.to_s.rjust(3)} V:#{@value2.to_s.rjust(3)} B:#{@black_position.to_s.rjust(2)}]"
	end # to_s

	# to hash
	def to_hash
		{
			:name           => :mondrian,
			:side           => @side,
			:crossover      => @crossover,
			:direction      => @direction,
			:position       => @position,
			:value1         => @value1,
			:value2         => @value2,
			:black_position => @black_position
		}
	end
end # Fgrn::MondrianPortionDefinition

