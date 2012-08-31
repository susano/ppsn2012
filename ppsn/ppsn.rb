require 'ppsn/run_experiment_set'

experiment_set = {
	:experiments => [:spb_10_01],
#	:experiments => [:spb_nv_10_01],
#	:experiments => [:dpb_nv_01],
#	:experiments => [:spb_10_11],
#	:genomes     => [:fgrn_negative],
	:genomes     => [:fgrn_original],
#	:genomes     => [:rnn],
#	:genomes     => [:imro],
	:searchs     => [:fga]
#	:searchs     => [:alps]
}

#run_count = 1
run_count = 3
#run_count = 10
#run_count = 10
#run_count = 50

run_experiment_set(
	:set       => experiment_set,
	:run_count => run_count,
	:basename  => 'fgrn_original'
)

