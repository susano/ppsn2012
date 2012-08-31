$TESTING = false

require 'metaheuristics/metaheuristic_init_factory'
require 'genome_init_factory'

require 'ppsn/experiments'
require 'ppsn/genomes'
require 'ppsn/searchs'

require 'yaml'
require 'threadify'

CPU_COUNT = 3
#CPU_COUNT = 1

# run experiment set
def run_experiment_set(options)

	set       = options[:set      ] or raise ArgumentError
	run_count = options[:run_count] or raise ArgumentError
	basename  = options[:basename ] or raise ArgumentError

	genome_ids = set[:genomes]
	search_ids = set[:searchs]

	definition = {
		:genomes     => Hash[genome_ids.zip(genome_ids.collect{ |id| $genomes[id] })],
		:searchs     => Hash[search_ids.zip(search_ids.collect{ |id| $searchs[id] })],
		:experiments => set[:experiments]
	}

	# initialise overall result file content
	data = {}
	data[:run_count ] = run_count
	data[:definition] = definition

	# generate individual experiments
	combinations       = []
	combinations_index = []
	definition[:experiments].each do |eid|
		definition[:searchs].each do |sid, s|
			definition[:genomes].each do |gid, g|
				combinations << {
					:experiment  => $experiments[eid],
					:genome_init => GenomeInitFactory.from_definition(g),
					:search_init => MetaheuristicInitFactory.from_definition(s)
				}

				combinations_index << {
					:experiment  => eid,
					:genome_init => gid,
					:search_init => sid
				}
			end
		end
	end

	#	for each combination of genome, search, and experiment
#	combinations_result = combinations.threadify(CPU_COUNT) do |c|

	experiment_id = Time.now.to_i.to_s

	combinations_result = combinations.collect do |c|
		
	  log_id_string = c.__id__.to_s

		experiment  = c[:experiment ]   # experiment
		genome_init = c[:genome_init]   # genome_init
		search_init = c[:search_init]   # search_init

		evaluator_init  = experiment[:evaluator_block_init] # evaluator_init
		evaluations_max = experiment[:evaluations_max] # evaluations_max 
		fitness_max     = experiment[:fitness_max    ] # fitness_max
		input_count     = experiment[:input_count    ] # input_count
		output_count    = experiment[:output_count   ] # output_count

		# each run
		c_results = (0...run_count).to_a.threadify(CPU_COUNT) do |run|

			# search
			evaluator = evaluator_init.call
			search = search_init.call(
				:genome_init => lambda{ genome_init.call(input_count, output_count) },
				:evaluator   => evaluator)

			evaluations = []
			fitnesses   = []

			highest_fitness            = nil
			highest_fitness_evaluation = nil
			evaluations_success        = nil
#			phenotype_evaluations_success = nil

			while search.results.evaluation < evaluations_max

#				$current_min_update_count = $max_update_count
				search.run_once
#				$max_update_count = [$max_update_count, ($current_min_update_count * 1.5).to_i].min

				# check new highest fitness
				results = search.results
				best    = results.best
				if highest_fitness.nil? || best[:fitness] > highest_fitness 
					highest_fitness            = best[:fitness]
					highest_fitness_evaluation = best[:evaluation]

					fitnesses   << highest_fitness
					evaluations << highest_fitness_evaluation
				
					# log improvement
#					$stdout << "info #{log_id_string} run #{run}, generation #{search.generation}, fitness max #{highest_fitness}, pheno eval #{evaluator.phenotype_evaluations}\n"
					$stdout << "info #{log_id_string} run #{run}, generation #{results.generation}, fitness max #{highest_fitness}\n"
					best_genome = best[:solution]
					genome_string = best_genome.to_s
					genome_string.each_line do |line|
						$stdout << "debug #{log_id_string} fittest genome #{line}"
					end
		
					File.open("output/genome-#{experiment_id}-#{log_id_string}-run_#{run.to_s.rjust(2, '0')}-eval_#{highest_fitness_evaluation.to_s.rjust(5, '0')}-fitness_#{highest_fitness.to_s.rjust(8, '0')}.yaml", 'w+'){ |f| YAML.dump(best_genome.to_hash, f) }
				
					# check fitness max reached
					if highest_fitness == fitness_max
						evaluation_success = highest_fitness_evaluation
#						phenotype_evaluations_success = evaluator.phenotype_evaluations

						break
					end
				else
				# log no improvement
#					$stdout << "info #{log_id_string} run #{run}, generation #{search.generation}, pheno eval #{evaluator.phenotype_evaluations}\n"
					$stdout << "info #{log_id_string} run #{run}, generation #{results.generation}\n"
				end
				$stdout.flush
			end

			# run result
			{
				:combination_id     => c.__id__,
				:fitnesses          => fitnesses,
				:evaluations        => evaluations,
				:evaluation_success => evaluation_success
#				:phenotype_evaluations => phenotype_evaluations_success
			}
		end

		c_results
	end

	# here we've run all combinations
	# fill in results hash
	combination_count = combinations.size

	hash = {}

	combination_count.times do |i|
		c   = combinations[       i]
		idx = combinations_index[ i]
		r   = combinations_result[i]

		h1 = (hash[idx[:experiment]] ||= {})
		h2 = (h1[  idx[:genome_init]] ||= {})

		assert{ h2[idx[:search_init]].nil? }
		h2[idx[:search_init]] = r
	end

	data[:results] = hash

	filename = "#{Time.now.strftime('%Y%m%d-%H%M%S')}-#{experiment_id}-#{basename}.yaml"
	File.open(filename, 'w') do |f|
		YAML.dump(data, f)
	end
end # run_experiment_set



#while search.results.evaluation < evaluations_max
#	
#	search.run_once
#
#	# save population genomes
#	search.population.each do |individual|
#		genome = individual.solution
#	end
#	results = search.results  
#	$stdout << "info generation #{results.generation} fitness max #{results.best[:fitness]}\n"
#	$stdout.flush
#	break if results.best[:fitness] == fitness_max
#end


