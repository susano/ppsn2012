require 'fgrn/fgrn'
require 'fgrn/gene_type'
require 'fgrn/protein_definition'

#--
# FIX remove fields duplicate to system settings
# FIX add output X initialisation
	# behavioural output x
	#		if geneType == Gene::Type::BEHAVIOURAL
	#			gene.outputX = rand * OUTPUT_X_INITIATISATION_RANGE -
	#				(OUTPUT_X_INITIATISATION_RANGE / 2)
	#		end
class Fgrn::Gene

	attr_reader \
		:promoter_definition,
		:output_definition,
		:type,
		:affinity_threshold,
		:concentration_threshold

	# new random
	def self.new_random(options)
		promoter_init     = options[:promoter_init    ] || (raise ArgumentError)
		output_init       = options[:output_init      ] || (raise ArgumentError)
		type              = options[:type             ] || (raise ArgumentError)
		at_mutation_range = options[:at_mutation_range] || (raise ArgumentError)
		at_init_range     = options[:at_init_range    ] || (raise ArgumentError)
		ct_init_range     = options[:ct_init_range    ] || (raise ArgumentError)
		ct_init_centered  = options[:ct_init_centered ] || false
		system_settings   = options[:system_settings  ] || (raise ArgumentError)

		self.new(
			:promoter_definition     => promoter_init.call,
			:output_definition       => output_init.call,
			:at_mutation_range       => at_mutation_range,
			:affinity_threshold      => ((rand - 0.5) * at_init_range).to_i,
			:concentration_threshold => (ct_init_centered ? (2.0 * (rand - 0.5)) : rand) * ct_init_range,
			:type                    => Fgrn::GeneType.new(Fgrn::GeneType::TYPE[type]),
			:system_settings         => system_settings
		)
	end

	# from hash
	def self.from_hash(hash, system_settings)
		self.new(
			:promoter_definition     => Fgrn::ProteinDefinition.from_hash(hash[:promoter_definition]),
			:output_definition       => Fgrn::ProteinDefinition.from_hash(hash[:output_definition  ]),
			:at_mutation_range       => hash[:at_mutation_range      ],
			:affinity_threshold      => hash[:affinity_threshold     ],
			:concentration_threshold => hash[:concentration_threshold],
			:type                    => Fgrn::GeneType.from_hash(hash[:type]),
			:system_settings         => system_settings)
	end

	# ctor
	def initialize(options)
		@promoter_definition     = options[:promoter_definition    ] || (raise ArgumentError)
		@output_definition       = options[:output_definition      ] || (raise ArgumentError)
		@at_mutation_range       = options[:at_mutation_range      ] || (raise ArgumentError)
		@affinity_threshold      = options[:affinity_threshold     ] || (raise ArgumentError)
		@concentration_threshold = options[:concentration_threshold] || (raise ArgumentError)
		@type                    = options[:type                   ] || (raise ArgumentError)
		@system_settings         = options[:system_settings        ] || (raise ArgumentError)
	end # ctor

	# clone
	def clone
		Fgrn::Gene.new(
			:promoter_definition     => @promoter_definition.clone,
			:output_definition       => @output_definition.clone,
			:at_mutation_range       => @at_mutation_range,
			:affinity_threshold      => @affinity_threshold,
			:concentration_threshold => @concentration_threshold,
			:type                    => @type.clone,
			:system_settings         => @system_settings
		)
	end # clone

	# mutate this
	def mutate!(mutation_rate)
		@promoter_definition.mutate!(mutation_rate)
		@output_definition.mutate!(  mutation_rate)
		@type.mutate!(               mutation_rate) if @system_settings[:gene_type_mutations]

		@affinity_threshold      += ((rand - 0.5) * @at_mutation_range).to_i        if rand < mutation_rate
		@concentration_threshold +=  (rand - 0.5) * Fgrn::Concentration::SATURATION if rand < mutation_rate
	end # mutate!

	# crossover
	def crossover(gene)
		Fgrn::Gene.new(
			:promoter_definition      => @promoter_definition.crossover(gene.promoter_definition),
			:output_definition        => @output_definition.crossover(  gene.output_definition),
			:affinity_threshold       => [@affinity_threshold     , gene.affinity_threshold     ][rand(2)],
			:concentration_threshold  => [@concentration_threshold, gene.concentration_threshold][rand(2)],
			:type                     => [@type                   , gene.type                   ][rand(2)].clone,
			:at_mutation_range        => @at_mutation_range, # constant
			:system_settings          => @system_settings
		)
	end

	# to hash
	def to_hash
		{
			:promoter_definition     => @promoter_definition.to_hash,
			:output_definition       => @output_definition.to_hash,
			:at_mutation_range       => @at_mutation_range,
			:affinity_threshold      => @affinity_threshold,
			:concentration_threshold => @concentration_threshold,
			:type                    => @type.to_hash
		}
	end

	# to string
	def to_s
		"[#{type.to_s} "                                      +
		"#{@promoter_definition} "                            +
		"AT:#{@affinity_threshold.to_s.rjust(6)} "            +
		"CT:#{('%.3f' % @concentration_threshold).rjust(7)} " +
		"#{@output_definition}]"
	end # to_s
end # Fgrn::Gene

