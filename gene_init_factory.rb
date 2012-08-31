require 'fgrn/gene'
require 'fgrn/protein_definition_init_factory'

class GeneInitFactory

	# from definition
	def self.from_definition(definition)
		name = definition[:name]
		case(name)

		# fgrn
		when :fgrn

			promoter_definition = definition[:promoter_definition] || (raise ArgumentError)
			output_definition   = definition[:output_definition  ] || (raise ArgumentError)

			args = {
				:promoter_init     => Fgrn::ProteinDefinitionInitFactory.from_definition(promoter_definition),
				:output_init       => Fgrn::ProteinDefinitionInitFactory.from_definition(output_definition),
#				:system_settings   => definition[:system_settings  ] || (raise ArgumentError)
				:at_mutation_range => definition[:at_mutation_range] || (raise ArgumentError),
				:at_init_range     => definition[:at_init_range    ] || (raise ArgumentError),
				:ct_init_range     => definition[:ct_init_range    ] || (raise ArgumentError),
				:ct_init_centered  => !!definition[:ct_init_centered]
			}

			lambda do |type, system_settings|
				Fgrn::Gene.new_random(args.merge(
					:type            => type,
					:system_settings => system_settings
				))
			end
		else raise ArgumentError, "Unknown gene type '#{name}'" end
	end # from_definition
end # GeneInitFactory

