require 'gene_init_factory'
require 'fgrn/genome'
require 'rnn/genome'
require 'imro/genome'

class GenomeInitFactory

	# from definition
	def self.from_definition(definition)
		name = definition[:name]
		case(name)

		# imro
		when :imro

			regulatory_count = definition[:regulatory_count] || (raise ArgumentError)
			input            = definition[:input           ] || (raise ArgumentError)
			promoter         = definition[:promoter        ] || (raise ArgumentError)
			activation       = definition[:activation      ] || (raise ArgumentError)
			protein_output   = definition[:protein_output  ] || (raise ArgumentError)
			mpp              = definition[:mpp             ] || (raise ArgumentError)

			args = {
				:regulatory_count => regulatory_count,
				:input            => input,
				:promoter         => promoter,
				:activation       => activation,
				:protein_output   => protein_output,
				:mpp              => mpp
			}

			lambda do |input_count, output_count|
				Imro::Genome.new_random(args.merge(
					:input_count  => input_count,
					:output_count => output_count
				))
			end

		# fgrn
		when :fgrn
			gene_definition  = definition[:gene_definition ] || (raise ArgumentError)
			regulatory_count = definition[:regulatory_count] || (raise ArgumentError)
			system_settings  = definition[:system_settings ] || (raise ArgumentError)

			args = {
				:gene_init       => GeneInitFactory.from_definition(gene_definition),
				:system_settings => system_settings
			}

			lambda do |input_count, output_count|
				composition = {
					:environmental => [input_count, 1].max,
					:receptor      => 1,
					:regulatory    => regulatory_count,
					:behavioural   => output_count
				}

				Fgrn::Genome.new_random(args.merge(
					:composition => composition))
			end

		# rnn
		when :rnn
			node_count = definition[:node_count] || (raise ArgumentError)
			recurrent  = definition[:recurrent ] || false

			args = {
				:node_count => node_count,
				:recurrent  => recurrent
			}

			lambda do |input_count, output_count|
				Rnn::Genome.new_random(args.merge(
					:input_count  => input_count,
					:output_count => output_count
				))
			end

		else raise ArgumentError, "Unknown genome type '#{name}'" end
	end
end # GenomeInitFactory

