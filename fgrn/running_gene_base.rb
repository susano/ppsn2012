require 'fgrn/fgrn'

class Fgrn::RunningGeneBase

	attr_reader :promoter_protein, :output_protein

	# ctor
	def initialize(gene)
		@promoter_protein = gene.promoter_definition.new_protein
		@output_protein   = gene.output_definition.new_protein
	end

	# details string
	def details_string; raise NotImplementedError; end

end # Fgrn::RunningGeneBase

