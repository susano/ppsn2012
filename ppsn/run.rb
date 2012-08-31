require 'fgrn/genome'
require 'ppsn/experiments'
require 'yaml'
require 'display_run'

# check arguments
if ARGV.size != 2
	$stderr << "Usage: #{$0} EXPERIMENT GENOME_YAML_FILE\n"
	exit 1
end

experiment_name = ARGV[0]
genome_file     = ARGV[1]

# load experiment
experiment = $experiments[experiment_name.to_sym]
if experiment.nil?
	$stderr << "Error: no such experiment '#{experiment_name}'\n"
	exit 2
end

#require 'pp'
display_run = Fgrn::DisplayRun.new

# load genome
genome_hash = YAML.load(File.read(genome_file))
#pp genome_hash
genome = Fgrn::Genome.from_hash(genome_hash)

fitness_max = experiment[:fitness_max         ] # fitness_max
problem     = experiment[:evaluator_class_init].call.problem
controller  =
	genome.new_controller(
		problem.input_count,
		problem.output_count,
		problem.input_type,
		problem.output_type)
	
max_update_count = experiment[:max_update_count] || experiment[:fitness_max]

update_count = 0
while update_count < max_update_count
	stop_running_flag = !problem.run_once(controller)
	details = problem.current_run
	$stdout << "#{update_count.to_s.rjust(6)} #{controller.details_string} #{details[:actions][-1].to_s.rjust(4)}\n"
	display_run.add_controller_state(controller)

	update_count += 1
	break if stop_running_flag
end

#File.open('blah.pgm', 'w+') do |f|
#	f.write(
#		display_run.to_pgm(
#			:row_height  => 16,
#			:cell_width  => 16,
#			:level_count => 200))
#end

File.open('blah.ppm', 'w+') do |f|
	f.write(
		display_run.to_ppm(
			:row_height           => 16,
			:cell_width           => 16,
			:cytoplasm_cell_width => 2,
			:gene_margin          => 1,
#			:category_margin      => 2))
			:category_margin      => 10))
end

