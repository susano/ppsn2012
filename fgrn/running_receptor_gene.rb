require 'fgrn/fgrn'
require 'fgrn/running_gene_base'

class Fgrn::RunningReceptorGene < Fgrn::RunningGeneBase

	# ctor
	def initialize(gene, system_settings)
		super(gene)
	end

	# details string
	def details_string
		"C"
	end
end # Fgrn::RunningReceptorGene


