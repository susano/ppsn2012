require 'fgrn/fgrn'
require 'fgrn/running_activable_gene'

class Fgrn::RunningBehaviouralGene < Fgrn::RunningActivableGene

	attr_reader :output

	# ctor
	def initialize(gene, system_settings)
		super(gene, system_settings)
		@output          = 0.0
		@system_settings = system_settings
	end

	# update
	def update(cytoplasm)
		activate(cytoplasm) do
			activation_check = @system_settings[:behavioural_activation_ct_check]
			if (!activation_check || @mean_concentration >= @concentration_threshold)
				sign = (@affinity_threshold > 0.0) ? 1.0 : -1.0
				@output = sign * (@mean_concentration - @concentration_threshold)

				true
			else
				@output = 0.0

				false
			end
		end
	end # update

	# details string
	def details_string
		"#{@activated ? '+' : '-'}B#{super} #{('%.2f' % @output).rjust(6)}"
	end
end # Fgrn::RunningBehaviouralGene

