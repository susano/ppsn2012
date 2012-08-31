require 'fgrn/fgrn'
require 'fgrn/running_gene_base'
require 'fgrn/concentration'

class Fgrn::RunningEnvironmentalGene < Fgrn::RunningGeneBase

	attr_reader :concentration

	def concentration=(c)
		do_set_concentration(c)
	end

	# ctor
	def initialize(gene, system_settings)
		super(gene)
		do_set_concentration(Fgrn::Concentration::SATURATION)
	end

	# details string
	def details_string
		"E[#{('%d' % @concentration).rjust(3)}]"
	end

private

	def do_set_concentration(c)
		@concentration = c
		@promoter_protein.concentration.fill(c)
	end
end # Fgrn::RunningEnvironmentalGene

