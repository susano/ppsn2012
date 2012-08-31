require 'imro/imro'
require 'imro/protein'

class Imro::ProteinOutput

	attr_reader \
		:output_scale,
		:levels,
		:lifespan

	# new random
	def self.new_random(options)
		protein_output_scale_init_range = options[:protein_output_scale_init_range] || (raise ArgumentError)
		protein_output_lifespan_max     = options[:protein_output_lifespan_max    ] || (raise ArgumentError)
		protein_level_count             = options[:protein_level_count            ] || (raise ArgumentError)
		protein_vector_size             = options[:protein_vector_size            ] || (raise ArgumentError)

		# output scale
		scale_init_range_first = protein_output_scale_init_range.first
		scale_init_range_last  = protein_output_scale_init_range.last
		output_scale = scale_init_range_first + rand * (scale_init_range_last - scale_init_range_first)

		# levels
		levels = Array.new(protein_vector_size){ rand(protein_level_count) - (protein_level_count / 2) }

		# lifespan
		lifespan = [1, rand(protein_output_lifespan_max)].max

		# result
		self.new(
			:output_scale   => output_scale,
			:levels         => levels,
			:lifespan       => lifespan,
			:mutation_delta => {
				:output_scale => (scale_init_range_last - scale_init_range_first) / 4.0,
				:levels       => [protein_level_count         / 2, 1].max,
				:lifespan     => [protein_output_lifespan_max / 2, 1].max })
	end

	# from hash
	def self.from_hash(hash)
		self.new(
			:output_scale   => (hash[:output_scale  ] || (raise ArgumentError)),
			:levels         => (hash[:levels        ] || (raise ArgumentError)).clone,
			:lifespan       => (hash[:lifespan      ] || (raise ArgumentError)),
			:mutation_delta => (hash[:mutation_delta] || (raise ArgumentError)).clone)
	end

	# new random single
	def self.new_random_single(options)
		protein_output_scale_init_range = options[:protein_output_scale_init_range] || (raise ArgumentError)
		protein_output_lifespan_max     = options[:protein_output_lifespan_max    ] || (raise ArgumentError)
		protein_level_count             = options[:protein_level_count            ] || (raise ArgumentError)
		protein_vector_size             = options[:protein_vector_size            ] || (raise ArgumentError)
		index                           = options[:index                          ] || (raise ArgumentError)

		# output scale
		scale_init_range_first = protein_output_scale_init_range.first
		scale_init_range_last  = protein_output_scale_init_range.last
		output_scale = scale_init_range_first + rand * (scale_init_range_last - scale_init_range_first)

		# levels
#		levels = Array.new(protein_vector_size){ rand(protein_level_count) - (protein_level_count / 2) }
		levels = Array.new(protein_vector_size, -protein_level_count)
		levels[index] = protein_level_count

		lifespan = 1

		# result
		self.new(
			:output_scale   => output_scale,
			:levels         => levels,
			:lifespan       => lifespan,
			:mutation_delta => {
				:output_scale => (scale_init_range_last - scale_init_range_first) / 4.0,
				:levels       => [protein_level_count         / 2, 1].max,
				:lifespan     => [protein_output_lifespan_max / 2, 1].max })
	end

	# ctor
	def initialize(options)
		@output_scale   = options[:output_scale  ] || (raise ArgumentError)
		@levels         = options[:levels        ] || (raise ArgumentError)
		@lifespan       = options[:lifespan      ] || (raise ArgumentError)
		@mutation_delta = options[:mutation_delta] || (raise ArgumentError)
	end

	# clone
	def clone
		Imro::ProteinOutput.new(
			:output_scale   => @output_scale,
			:levels         => @levels.clone,
			:lifespan       => @lifespan,
			:mutation_delta => @mutation_delta)
	end

	# output
	def output(activation)
		(activation.abs > (1.0 / 1_000_000_000)) ?
			Imro::Protein.new(
				:value    => activation * @output_scale,
				:levels   => @levels,
				:lifespan => @lifespan) : nil
	end

	# output_value
	def output_value(value)
		Imro::Protein.new(
			:value    => value * @output_scale,
			:levels   => @levels,
#			:lifespan => @lifespan)
			:lifespan => 1)
	end

	# mutate this
	def mutate!(mutation_rate)
		@output_scale += 2.0 * (rand - 0.5) * @mutation_delta[:output_scale]   if rand < mutation_rate
		@lifespan     +=  (2 * (rand - 0.5) * @mutation_delta[:lifespan]).to_i if rand < mutation_rate
		@levels.size.times do |i|
			@levels[i] += (2.0 * (rand - 0.5) * @mutation_delta[:levels]).to_i if rand < mutation_rate
		end
	end
		
	# crossover
	def crossover(gene)
		Imro::ProteinOutput.new(
			:output_scale   => [@output_scale, gene.output_scale][rand(2)],
			:levels         => [@levels      , gene.levels      ][rand(2)].clone,
			:lifespan       => [@lifespan    , gene.lifespan    ][rand(2)],
			:mutation_delta => @mutation_delta)
	end

	# to_s
	def to_s
		"OS:#{('%.2f' % @output_scale).rjust(6)} LF:#{@lifespan.to_s.rjust(2)}, LV:|#{@levels.collect{ |l| l.to_s.rjust(3) }.join('|')}|"
	end

	# to hash
	def to_hash
		{
			:output_scale   => @output_scale,
			:levels         => @levels.clone,
			:lifespan       => @lifespan,
			:mutation_delta => @mutation_delta.clone
		}
	end
end # Imro::ProteinOutput

