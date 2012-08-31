require 'imro/imro'

class Imro::Mpp

#	attr_accessor :inputs

	# ctor
	def initialize(options)
#		@input_count         = options[:input_count        ] || (raise ArgumentError)
		@output_count        = options[:output_count       ] || (raise ArgumentError)
		@protein_level_count = options[:protein_level_count] || (raise ArgumentError)
		@protein_vector_size = options[:protein_vector_size] || (raise ArgumentError)

		@proteins = []
#		@inputs   = Array.new(@input_count, 0.0)
		@state    = nil
	end

	# age the proteins
	def age!
		@proteins.each{    |p|  p.age!  }
		@proteins.select!{ |p| !p.dead? }
		@state = nil
	end

	# add a protein
	def add_protein(protein)
		@proteins << protein
		@state = nil
	end

	# state
	def state
		if @state.nil?
			size = @protein_vector_size
			best_levels   = Array.new(size, 0)
			best_proteins = Array.new(size){ [] }

			@proteins.each do |p|
				p_levels = p.levels
				size.times do |i|
					if p_levels[i] > best_levels[i]
						best_levels[i] = p_levels[i]
						best_proteins[i] = [p]
					elsif p_levels[i] == best_levels[i]
						best_proteins[i] << p
					end
				end # size.times
			end # @proteins.each

			vector = Array.new(size) do |i|
				v = 0.0
				proteins = best_proteins[i]
				proteins.each{ |p| v += p.value }

				(proteins.size != 0) ? v / proteins.size : v
			end

#			@state = @inputs + vector
			@state = vector
		end # @state.nil?

		@state
	end

	# to_s
	def to_s
		@proteins.collect{ |p| p.to_s }.join("\n") + "\n" +
		"|#{self.state.collect{ |v| ('%.1f' % v).rjust(4) }.join('|')}|"
	end
end # Imro::Mpp
	
#		# settings
#		settings = @genome.settings
#		@maximum_cycle_count  = settings[:maximum_cycle_count ]
#		@zero_internal_vector = settings[:zero_internal_vector]

