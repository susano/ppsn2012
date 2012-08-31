require 'fgrn/fgrn'
require 'fgrn/running_gene_base'

class Fgrn::RunningActivableGene < Fgrn::RunningGeneBase

	attr_reader \
		:affinity_threshold,
 	 	:concentration_threshold,
		:activated,
		:activation_probability,
		:matching_score,
		:mean_concentration

	# ctor
	def initialize(gene, system_settings)
		super(gene)

		@system_settings = system_settings

		@affinity_threshold      = gene.affinity_threshold
		@concentration_threshold = gene.concentration_threshold

		@activated              = false
		@activation_probability = nil
		@matching_score         = nil
		@mean_concentration     = nil
	end

	# activate
	def activate(cytoplasm, &block)
		@activated              = false
		@activation_probability = 0.0

		# compute difference
 		cytoplasm.difference_to_promoter(@promoter_protein)
		@matching_score     = cytoplasm.difference
		@mean_concentration = cytoplasm.mean_concentration

		# activation probability
		ct = @system_settings[:activation_probability_ct]
		cs = @system_settings[:activation_probability_cs]
		@activation_probability = 
		 (@affinity_threshold >= 0.0) ?
				      (Math::tanh((@matching_score - @affinity_threshold     - ct) / cs) + 1.0) / 2.0 :
				1.0 - (Math::tanh((@matching_score - @affinity_threshold.abs - ct) / cs) + 1.0) / 2.0

		# probabilistic activation, calling the associated block
		@activated = (rand <= @activation_probability) && block.call
	end

	# details string
	def details_string
		ct = @system_settings[:activation_probability_ct]
		cs = @system_settings[:activation_probability_cs]
		"[#{@matching_score.to_i.to_s.rjust(5)} #{('%.1f' % @mean_concentration ).rjust(5)} #{('%.2f' % @activation_probability).rjust(4)}]"
	end
end # Fgrn::RunningActivableGene

