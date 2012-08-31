
#--
# FIX move the whole thing to genome ? rename to GenomeEvaluator ?
class Evaluator

	attr_reader :problem

	def initialize(problem)
		@problem = problem
	end

	def evaluate(genome)
		controller = genome.new_controller(@problem.input_count, @problem.output_count, @problem.input_type, @problem.output_type)

#		$stderr << genome.to_s
#		genome.fitness = @problem.run(controller)
		f = @problem.run(controller)
#		$stderr << "evaluator - #{genome.__id__.to_s.rjust(10)} - #{f.to_s.rjust(5)}\n"
#		f
	end

	def phenotype_evaluations
		@problem.phenotype_evaluations
	end

	def to_description
		@problem.description
	end
end # Evaluator

