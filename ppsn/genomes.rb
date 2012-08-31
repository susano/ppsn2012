require 'fgrn/concentration'
#require 'fgrn/vector_chemistry'

# protein definitions
protein_definitions = {
	:fractal   => {
		:name               => :fractal,
		:side               => 15,
		:crossover          => :parameter_swap,
		:random_coordinates => false},

	:mondrian  => {
		:name            => :mondrian,
		:side            => 15,
		:component_count => 4,
#		:component_count => 3,
#		:component_count => 2,
#		:component_count => 1,
		:crossover       => :parameter_swap},

	:landscape => {
		:name                  => :landscape,
		:protein_length        => 15 * 15,
		:max_value             => 128,
		:max_black_coefficient => 0.7,
		:crossover             => :parameter_swap}
}


# gene: fgrn
fgrn_gene_definition = {
	:name                => :fgrn, 
	:promoter_definition => protein_definitions[:fractal],
	:output_definition   => protein_definitions[:fractal],
	:at_mutation_range   => 2 * 16_384,
	:at_init_range       => 20_000,
	:ct_init_range       => Fgrn::Concentration::SATURATION,
	:ct_init_centered    => false
}

fgrn_system_settings_improved = {
	:has_centered_inputs             => true,
	:activation_probability_ct       => 0.0,
	:activation_probability_cs       => 20.0,
	:concentration_persistence_coeff => 0.8,
	:concentration_minimum_diffusion => 0.2,
	:output_cw                       => 30.0,
	:output_ci                       => 2.0
#	:chemistry                       => VectorChemistry
}

fgrn_system_settings_patterns = {
	:has_centered_inputs             => false,
	:activation_probability_ct       => 0.0,
	:activation_probability_cs       => 20.0,
	# 50 ?
	:concentration_persistence_coeff => 0.8,
	:concentration_minimum_diffusion => 0.2,
	:output_cw                       => 30.0,
	:output_ci                       => 2.0,
#	:chemistry                       => VectorChemistry,
	:genome_structure_mutations      => false,
	:gene_type_mutations             => false,
	:behavioural_activation_ct_check => true
}
# TODO outputX possibility in real output

# genome: fgrn(gen)

# genome
# - fgrn

fgrn_dev_pattern = {
	:name             => :fgrn,
	:gene_definition  => fgrn_gene_definition,
#	:regulatory_count => 3,
	:regulatory_count => 4,
#	:regulatory_count => 6,
#	:system_settings  => fgrn_system_settings_patterns
	:system_settings  => fgrn_system_settings_improved
}


# - agrn
agrn_dev_pattern = {
	:name         => :agrn,
#	:hidden_count => 0,
	:hidden_count => 4,
#	:hidden_count => 6,
#	:vector_size  => 6
	:vector_size  => 8
#	:vector_size  => 16
}

# - sgrn genome
sgrn_genome = {
	:name                  => :sgrn,
	:maximum_cycle_count   => 1,
#	:regulatory_node_count => 4,
	:regulatory_node_count => 0,
	:output_node_count     => 1,
#	:output_node_count     => 3,
#	:output_node_count     => 10,
#	:output_node_count     => 40,
#	:internal_vector_size  => 8,
	:internal_vector_size  => 0,
	:level_count           => 8,
#	:zero_internal_vector  => false
	:zero_internal_vector  => true
}

# original fgrn
genome_fgrn_original = {
	:name             => :fgrn,
	:regulatory_count => 4,
	:gene_definition  => {
		:name                => :fgrn, 
		:promoter_definition => protein_definitions[:fractal],
		:output_definition   => protein_definitions[:fractal],
#		:promoter_definition => protein_definitions[:mondrian],
#		:output_definition   => protein_definitions[:mondrian],
#		:promoter_definition => protein_definitions[:landscape],
#		:output_definition   => protein_definitions[:landscape],
		:at_mutation_range   => 2 * 16_384,
		:at_init_range       => 20_000,
		:ct_init_range       => Fgrn::Concentration::SATURATION,
		:ct_init_centered    => false },
	:system_settings  => {
		:has_centered_inputs             => false,
		:activation_probability_ct       => 0.0,
		:activation_probability_cs       => 20.0,
		:concentration_persistence_coeff => 0.8,
		:concentration_minimum_diffusion => 0.2,
		:output_cw                       => 30.0,
		:output_ci                       => 2.0,
		:genome_structure_mutations      => true,
		:gene_type_mutations             => true,
		:regulatory_activation_ct_check  => false,
		:behavioural_activation_ct_check => false
	}
}

# fgrn improved for control initially
genome_fgrn_negative = {
	:name             => :fgrn,
	:regulatory_count => 4,
	:gene_definition  => {
		:name                => :fgrn, 
		:promoter_definition => protein_definitions[:fractal],
		:output_definition   => protein_definitions[:fractal],
		:at_mutation_range   => 2 * 16_384,
		:at_init_range       => 2 * 20_000,
		:ct_init_range       => Fgrn::Concentration::SATURATION,
		:ct_init_centered    => true },
	:system_settings  => {
		:has_centered_inputs             => true,
		:activation_probability_ct       => 0.0,
		:activation_probability_cs       => 20.0,
		:concentration_persistence_coeff => 0.8,
		:concentration_minimum_diffusion => 0.2,
		:output_cw                       => 30.0,
		:output_ci                       => 2.0,
		:genome_structure_mutations      => true,
		:gene_type_mutations             => true,
		:regulatory_activation_ct_check  => false,
		:behavioural_activation_ct_check => false
	}
}

# - imro genome
genome_imro = {
	:name => :imro,
#	:regulatory_count => 4,
	:regulatory_count => 2,
#	:regulatory_count => 1,
#	:regulatory_count => 0,
	:input            => {
#		:input_scale_init_range => (-64.0)..64.0 },
#		:input_scale_init_range => (-8.0)..8.0 },
		:input_scale_init_range => (-1.0)..1.0 },
#		:input_scale_init_range => (-0.0)..0.0 },
	:promoter         => {
		:weights_init_range     => (-8.0)..(8.0),
#		:masks_init_probability => 1.0 },
		:masks_init_probability => 0.5 },
	:activation       => {
		:activation_type        => :tanh_thresholded,
#		:activation_type        => :tanh,
		:k                      => 1.0,
		:input_scale_init_range => (-8.0)..(8.0) },
	:protein_output   => {
		:protein_output_scale_init_range => (-4.0)..(4.0),
		:protein_output_lifespan_max     => 8 },
	:mpp              => {
#		:protein_level_count => 128,
#		:protein_level_count => 2,
#		:protein_vector_size => 8 }
#		:protein_level_count => 16,
#		:protein_vector_size => 32 }
		:protein_level_count => 16,
		:protein_vector_size => 8 }
}

# - rnn
genome_rnn = {
	:name       => :rnn,
#	:node_count => 3,
#	:node_count => 6,
	:node_count => 4,
	:recurrent  => true 
}

$genomes = {
	:fgrn_original => genome_fgrn_original,
	:fgrn_negative => genome_fgrn_negative,
	:rnn           => genome_rnn,
	:imro          => genome_imro
}

