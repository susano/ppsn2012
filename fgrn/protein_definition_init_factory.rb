require 'fgrn/fgrn'
#require 'fgrn/array_protein_definition'
require 'fgrn/fractal_protein_definition'
require 'fgrn/landscape_protein_definition'
require 'fgrn/mondrian_portion_definition'
require 'fgrn/mondrian_protein_definition'

class Fgrn::ProteinDefinitionInitFactory

	def self.from_definition(definition)
		name = definition[:name]
		case(name)

		# array
		when :array

			protein_length = definition[:protein_length] || (raise ArgumentError)
			value_max      = definition[:value_max     ] || (raise ArgumentError)
			crossover      = definition[:crossover     ] || (raise ArgumentError)
			black_coeff    = definition[:black_coeff   ] || (raise ArgumentError)

			args = {
				:protein_length => protein_length,
				:value_max      => value_max,
				:crossover      => crossover,
				:black_coeff    => black_coeff
			}

			lambda do 
				Fgrn::ArrayProteinDefinition.new_random(args)
			end

		# fractal
		when :fractal

			side               = definition[:side              ] || (raise ArgumentError)
			crossover          = definition[:crossover         ] || (raise ArgumentError)
			random_coordinates = definition[:random_coordinates] || false

			raise ArgumentError unless [:none, :parameter_mix, :parameter_swap].include?(crossover)

			args = {
				:side               => side,
				:crossover          => crossover,
				:random_coordinates => random_coordinates
			}

			lambda do
				Fgrn::FractalProteinDefinition.new_random(args)
			end

		# mondrian
		when :mondrian

			side            = definition[:side           ] || (raise ArgumentError)
			component_count = definition[:component_count] || (raise ArgumentError)
			crossover       = definition[:crossover      ] || (raise ArgumentError)
			raise ArgumentError unless [:none, :parameter_mix, :parameter_swap, :component_swap].include?(crossover)

			args = {
				:side      => side,
				:crossover => crossover
			}

			if component_count == 1

				lambda do
					Fgrn::MondrianPortionDefinition.new_random(args)
				end
			else
				raise ArgumentError unless component_count > 1

				lambda do
					Fgrn::MondrianProteinDefinition.new_random(args.merge(:component_count => component_count))
				end
			end

		# landscape
		when :landscape
			protein_length        = definition[:protein_length       ] || (raise ArgumentError)
			max_value             = definition[:max_value            ] || (raise ArgumentError)
			crossover             = definition[:crossover            ] || (raise ArgumentError)
			max_black_coefficient = definition[:max_black_coefficient] || (raise ArgumentError)

			args = {
				:protein_length        => protein_length,
				:max_value             => max_value,
				:crossover             => crossover,
				:max_black_coefficient => max_black_coefficient
			}

			lambda do
				Fgrn::LandscapeProteinDefinition.new_random(args)
			end
		else raise ArgumentError, "Unknown protein definition '#{name}'" end
	end # from_definition
end # Fgrn::ProteinDefinitionInitFactory

