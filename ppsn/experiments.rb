require 'evaluator_init_factory'
require 'evaluators/pattern_matching_evaluator'

# experiments
#
# - square root regression
#
#  TODO
#
# - pi pattern
#
#  TODO
#
# - pi algorithm
#
#  TODO
#
# - SPB
#
# - DPB
#
# - JPB

# experiments: patterns

# X_X_X
# _X_X_
pattern_1 = [
	[true , false, true , false, true ],
	[false, true , false, true , false]]

# X___X
# _XXX_
pattern_2 = [
	[true , false, false, false, true ],
	[false, true , true , true , false]]

# ____XXXX____XXXX
pattern_3 = [[false, false, false, false, true, true, true, true, false, false, false, false, true, true, true, true]]

# aux: experiment pattern gen
experiment_pattern_gen = lambda do |patterns, check_edges| {
	:evaluator_init => lambda do 
		evaluator = PatternMatchingEvaluator.new(patterns)
		evaluator.check_edges = check_edges

		lambda do |genome|
			evaluator.evaluate(genome)
		end
	end,
	:input_count     => 0,
	:output_count    => patterns.size,
	:fitness_max     => 0,
	:evaluations_max => 20_000
}
end

experiment_pattern_1   = experiment_pattern_gen.call(pattern_1, false)
experiment_pattern_2   = experiment_pattern_gen.call(pattern_2, false)
experiment_pattern_3   = experiment_pattern_gen.call(pattern_3, false)
experiment_pattern_3we = experiment_pattern_gen.call(pattern_3, true)


# experiments: pole balancing
pb_fitness_max     = 1000
#pb_fitness_max     = 100_000
#pb_evaluations_max = 100_000
#pb_evaluations_max = 5_000
pb_evaluations_max = 10_000

# - spb
experiment_spb_gen = lambda do |pole_length, range_01, no_velocities = false|
	evaluator_class_init = EvaluatorInitFactory.from_definition(
		:name          => :single_pole_balancing,
		:range_01      => range_01,
		:fitness_max   => pb_fitness_max,
		:no_velocities => no_velocities)
 
	input_count = no_velocities ? 2 : 4

	{
		:evaluator_class_init => evaluator_class_init,
		:evaluator_block_init => lambda do 
			evaluator = evaluator_class_init.call

			lambda do |genome|
				evaluator.evaluate(genome)
			end
		end,
		:input_count     => input_count,
		:output_count    => 1,
		:fitness_max     => pb_fitness_max,
		:pole_length     => pole_length,
		:evaluations_max => pb_evaluations_max
	}
end

# full inputs
experiment_spb_05_11 = experiment_spb_gen.call(0.5, false)
experiment_spb_10_11 = experiment_spb_gen.call(1.0, false)
experiment_spb_20_11 = experiment_spb_gen.call(2.0, false)
experiment_spb_05_01 = experiment_spb_gen.call(0.5,  true)
experiment_spb_10_01 = experiment_spb_gen.call(1.0,  true)
experiment_spb_20_01 = experiment_spb_gen.call(2.0,  true)

# no velocities
experiment_spb_nv_05_11 = experiment_spb_gen.call(0.5, false, true)
experiment_spb_nv_10_11 = experiment_spb_gen.call(1.0, false, true)
experiment_spb_nv_20_11 = experiment_spb_gen.call(2.0, false, true)
experiment_spb_nv_05_01 = experiment_spb_gen.call(0.5,  true, true)
experiment_spb_nv_10_01 = experiment_spb_gen.call(1.0,  true, true)
experiment_spb_nv_20_01 = experiment_spb_gen.call(2.0,  true, true)


# - dpb
experiment_dpb_gen = lambda do |range_01, no_velocities = false|
	evaluator_class_init = EvaluatorInitFactory.from_definition(
		:name          => :double_pole_balancing,
		:fitness_max   => pb_fitness_max,
		:range_01      => range_01,
		:no_velocities => no_velocities)

	input_count = no_velocities ? 3 : 6

	{
		:evaluator_class_init => evaluator_class_init,
		:evaluator_block_init => lambda do
			evaluator = evaluator_class_init.call

			lambda do |genome|
				evaluator.evaluate(genome)
			end
		end,
		:input_count     => input_count,
		:output_count    => 1,
		:fitness_max     => pb_fitness_max,
		:evaluations_max => pb_evaluations_max
	}
end

# full inputs
experiment_dpb_01 = experiment_dpb_gen.call( true)
experiment_dpb_11 = experiment_dpb_gen.call(false)

# no velocities
experiment_dpb_nv_01 = experiment_dpb_gen.call( true, true)
experiment_dpb_nv_11 = experiment_dpb_gen.call(false, true)


# - jpb
experiment_jpb_gen = lambda do |range_01|
	evaluator_class_init = EvaluatorInitFactory.from_definition(
		:name        => :jointed_pole_balancing,
		:fitness_max => pb_fitness_max,
		:range_01    => range_01)

	{
		:evaluator_class_init => evaluator_class_init,
		:evaluator_block_init => lambda do
			evaluator = evaluator_class_init.call

			lambda do |genome|
				evaluator.evaluate(genome)
			end
		end,
		:input_count     => 6,
		:output_count    => 1,
		:fitness_max     => pb_fitness_max,
		:evaluations_max => pb_evaluations_max
	}
end
experiment_jpb_01 = experiment_jpb_gen.call(true)
experiment_jpb_11 = experiment_jpb_gen.call(false)


# experiments: acrobot
acrobot_max_update_count = 4_000
acrobot_evaluations_max  = 3_000

acrobot_evaluator_class_init = EvaluatorInitFactory.from_definition(
	:name             => :acrobot,
	:max_update_count => acrobot_max_update_count)

experiment_acrobot = {
	:evaluator_class_init => acrobot_evaluator_class_init,
	:evaluator_block_init => lambda do
		evaluator = acrobot_evaluator_class_init.call

		lambda do |genome|
			evaluator.call(genome)
		end
	end,
	:input_count     => 6,
	:output_count    => 3,
	:fitness_max     => acrobot_max_update_count,
	:evaluations_max => acrobot_evaluations_max
}


$experiments = {
	:pattern_1    => experiment_pattern_1,
	:pattern_2    => experiment_pattern_2,
	:pattern_3    => experiment_pattern_3,
	:pattern_3we  => experiment_pattern_3we,
	:spb_05_01    => experiment_spb_05_01,
	:spb_10_01    => experiment_spb_10_01,
	:spb_20_01    => experiment_spb_20_01,
	:spb_05_11    => experiment_spb_05_11,
	:spb_10_11    => experiment_spb_10_11,
	:spb_20_11    => experiment_spb_20_11,
	:spb_nv_05_01 => experiment_spb_nv_05_01,
	:spb_nv_10_01 => experiment_spb_nv_10_01,
	:spb_nv_20_01 => experiment_spb_nv_20_01,
	:spb_nv_05_11 => experiment_spb_nv_05_11,
	:spb_nv_10_11 => experiment_spb_nv_10_11,
	:spb_nv_20_11 => experiment_spb_nv_20_11,
	:dpb_01       => experiment_dpb_01,
	:dpb_11       => experiment_dpb_11,
	:dpb_nv_01    => experiment_dpb_nv_01,
	:dpb_nv_11    => experiment_dpb_nv_11,
	:jpb_01       => experiment_jpb_01,
	:jpb_11       => experiment_jpb_11,
	:acrobot      => experiment_acrobot
} 

