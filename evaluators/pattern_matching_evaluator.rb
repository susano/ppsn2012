require 'utils/assert'

class PatternMatchingEvaluator


	# ctor
	def initialize(patterns)
		assert{ !patterns.empty? }
		@patterns =
			patterns.collect do |p|
				p.collect do |v|
					if (v == true || v == 1)
						true
					elsif (v == false || v == 0)
						false
					else
						raise ArgumentError
					end
				end
			end
		@pattern_size = @patterns[0].size
		@check_edges  = false
	end

	# set check edges
	def check_edges=(check_edges)
		@check_edges   = check_edges
		@pattern_edges = @check_edges ? @patterns.collect{ |p| count_edges(p) } : nil
	end


	def evaluate(genome)
		controller = genome.newController(0, @patterns.size, :beginning, :boolean)

		values = Array.new(@patterns.size){ Array.new }
		@pattern_size.times do |i|
			controller.update
			@patterns.size.times{ |j| values[j] << controller.outputs[j] }
		end

		difference = 0
		@patterns.size.times do |i|
			@pattern_size.times do |j|
#				$stdout << "debug #{i}   #{j}\n"
				difference += 1 if @patterns[i][j] != values[i][j]
			end
		end

		fitness = -difference
#		$stdout << "debug fitness before edges #{fitness}\n"

		if @check_edges
#			$stdout << "debug checking edges count_edges(values[0]) #{count_edges(values[0])}  @pattern_edges[0] #{@pattern_edges[0]} \n"
			fitness -= Array.new(@patterns.size){ |i| (count_edges(values[i]) - @pattern_edges[i]).abs }.inject(&:+)
		end

		display_patterns(values, fitness)
#		$stderr << controller.to_s

		genome.fitness = fitness
	end

	def phenotype_evaluations;
		0
	end

private
	def display_patterns(patterns, fitness)
		output = ''
		patterns.each_with_index do |p, i|
			output << 'pattern ' + (i + 1).to_s + ': '
			p.each do |v|
				output << ((v) ? 'X' : '_')
			end
			output << " : " + fitness.to_s + "\n"
		end

		puts output
	end

	def count_edges(pattern)
		edge_sum = 0
		previous = nil
		pattern.each do |v|
			edge_sum += 1 if !previous.nil? && (previous != v)
			previous = v
		end

		edge_sum
	end
end # PatternMatchingEvaluator

