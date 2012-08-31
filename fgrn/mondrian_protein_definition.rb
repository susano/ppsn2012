#require 'cpp/grn.so'
require 'fgrn/fgrn'
require 'fgrn/mondrian_portion_definition' 
require 'fgrn/protein_definition'

require 'java'
java_import 'fgrn.MondrianProteinFactory'

# mondrian protein definition
class Fgrn::MondrianProteinDefinition < Fgrn::ProteinDefinition

	attr_accessor :operator, :operands

	# new random
	def self.new_random(options)
		component_count = options[:component_count] || (raise ArgumentError)
		side            = options[:side           ] || (raise ArgumentError)
		crossover       = options[:crossover      ] || (raise ArgumentError)

		# operands
		operands = Array.new(component_count){
			Fgrn::MondrianPortionDefinition.new_random(
 				:side      => side,
				:crossover =>	crossover)
		}

		# result
		self.new(
			:side     => side,
			:operator => [:min, :max][rand(2)],
			:operands => operands
		)
	end

	# from hash
	def self.from_hash(hash)
		self.new(
			:side     => hash[:side],
			:operator => hash[:operator],
			:operands => (hash[:operands] || (raise ArgumentError)).collect{ |o| Fgrn::MondrianPortionDefinition.from_hash(o) })
	end

	# ctor
	def initialize(options)
		@side     = options[:side    ] || (raise ArgumentError)
		@operator = options[:operator] || (raise ArgumentError)
		@operands = options[:operands] || (raise ArgumentError)
	end

	# clone
	def clone
		Fgrn::MondrianProteinDefinition.new(
			:side     => @side,
			:operator => @operator,
			:operands => @operands.collect{ |o| o.clone }
		)
	end

	# mutate!
	def mutate!(mutation_rate)
		# operands
		@operands.each do |o|
			o.mutate!(mutation_rate)
		end

		# operator
		@operator = (@operator == :min) ? :max : :min if rand <= mutation_rate
	end
	
	# crossover
	def crossover(definition)
		o = []
		o1 = @operands
		o2 = definition.operands

		# crossover each operand
		[o1.size, o2.size].min.times do |i|
			o << (o1[i].crossover(o2[i]))
		end

		# if o2 smaller, fill in with o1
		(o.size...o1.size).each do |i|
			o << o1[i].clone
		end

		# result
		Fgrn::MondrianProteinDefinition.new(
			:side     => @side,
			:operator => [@operator, definition.operator][rand(2)],
			:operands => o)
	end

	# new protein
	def new_protein
		if @operator == :min
			MondrianProteinFactory.new_mondrian_protein_min(@side, @operands)
		elsif @operator == :max
			MondrianProteinFactory.new_mondrian_protein_max(@side, @operands)
		else
			raise 'Invalid operator : ' + @operator.to_s
		end
	end

	# to_s
	def to_s
		"{#{@operator == :min ? '-' : '+'} #{@operands.join('')}}"
	end

	# to hash
	def to_hash
		{
			:side     => @side,
			:operator => @operator,
			:operands => @operands.collect{ |o| o.to_hash }
		}
	end
end # Fgrn::MondrianProteinDefinition

