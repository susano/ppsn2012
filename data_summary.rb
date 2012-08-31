require 'yaml'
require 'utils/enumerable_math'

raise ArgumentError if ARGV.size != 1

filename = ARGV[0]

h = YAML.load_file(filename)

results = h[:results]

results.each do |experiment, he|
	he.each do |genome, ge|
		ge.each do |search, array|
			run_count = array.size
			successful_count       = array.select{  |e| e[:evaluation_success] }.size
			final_fitnesses        = array.collect{ |e| e[:fitnesses][-1] }
			successful_evaluations = array.collect{ |e| e[:evaluation_success] }.select{ |e| e }
			phenotype_evaluations  = array.collect{ |e| e[:phenotype_evaluations] }.select{ |e| e }

			$stdout << "\n= #{experiment}, #{genome}, #{search}\n"
			$stdout << "  success #{successful_count}/#{run_count}\n"
			$stdout << "  final fitnesses : #{final_fitnesses.join(', ')}\n" if successful_count != run_count
			$stdout << "  successful evaluations : #{successful_evaluations.join(', ')}\n"
			$stdout << "  phenotype evaluations : #{phenotype_evaluations.join(', ')}\n"
			$stdout << "  stats final fitnesses: #{final_fitnesses.mean}(#{final_fitnesses.stddev})\n"
			$stdout << "  stats successful evaluations: #{successful_evaluations.mean}(#{successful_evaluations.stddev})\n"
			$stdout << "  stats phenotype evaluations: #{phenotype_evaluations.mean}(#{phenotype_evaluations.stddev})\n"
		end
	end
end

