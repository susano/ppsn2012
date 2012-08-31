
# search
search_mutation_rate = 0.1
#search_mutation_rate = 0.01

# - alps
alps_definition = {
	:name            => :alps,
#	:layer_size      => 100,
	:layer_size      => 25,
	:max_layer_count => 10,
#	:tournament_size => 10,
#	:tournament_size => 7,
#	:tournament_size => 5,
	:tournament_size => 4,
#	:tournament_size => 3,
#	:tournament_size => 2,
	:age_gap         => 10,
	:aging_scheme    => :polynomial,
#	:layer_elitism   => 3,
#	:layer_elitism   => 5,
	:layer_elitism   => 4,
#	:layer_elitism   => 2,
#	:layer_elitism   => 1,
	:overall_elitism => 0,
	:parents_from_previous_layer => false,
	:mutation_rate   => search_mutation_rate
}

# - fga
fga_definition = {
	:name                   => :fga,
	:population_size        => 100,
	:children_count         => 80,
#	:population_size        => 25,
#	:children_count         => 20,
	:mutation_rate          => search_mutation_rate,
	:parents_coeff          => 0.4,
	:random_parent_coeff    => 0.01,
	:age_max                => 10,
	:evaluate_children_only => false 
}


$searchs = {
	:alps => alps_definition,
	:fga  => fga_definition
}

