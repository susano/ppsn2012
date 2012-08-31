require 'fgrn/fgrn'
require 'fgrn/concentration'
require 'fgrn/running_activable_gene'

class Fgrn::RunningRegulatoryGene < Fgrn::RunningActivableGene

	attr_reader :concentration

	# ctor
	def initialize(gene, system_settings)
		super(gene, system_settings)

		do_set_concentration(0.0)
	end

	# decay concentration
	def decay_concentration
		persistence_coeff = @system_settings[:concentration_persistence_coeff]
		minimum_diffusion = @system_settings[:concentration_minimum_diffusion]
		do_set_concentration(Fgrn::Concentration.decay(concentration, persistence_coeff, minimum_diffusion))
	end

	# update
	def update(cytoplasm)
		activate(cytoplasm) do
			# output concentration to be added
			cw = @system_settings[:output_cw]
			ci = @system_settings[:output_ci]
			ct_check = @system_settings[:regulatory_activation_ct_check]
			activation = !ct_check || (@mean_concentration >= @concentration_threshold)
			if activation
				output_concentration = @mean_concentration * (Math::tanh((@mean_concentration - @concentration_threshold) / cw) / ci)

				# add output concentration
		  	do_set_concentration([[@concentration + output_concentration, Fgrn::Concentration::SATURATION].min, 0.0].max)
			end

			activation
		end
	end # update

	# details string
	def details_string
		"#{@activated ? '+' : '-'}R#{super}"
	end

private

	def do_set_concentration(c)
		@concentration = c
		@output_protein.concentration.fill(c)
	end
end # Fgrn::RunningRegulatoryGene

