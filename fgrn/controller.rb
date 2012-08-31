require 'fgrn/fgrn'
require 'fgrn/concentration'

# grn controller
class Fgrn::Controller

	attr_writer :inputs
	attr_reader :outputs

	attr_reader :running_genes, :cytoplasm

	# ctor
	def initialize(options)
		@system_settings = options[:system_settings] || (raise ArgumentError)
		@input_mode      = options[:input_mode     ] || :update
		@output_type     = options[:output_type    ] || :boolean
		genome           = options[:genome         ] || (raise ArgumentError)
		input_count      = options[:input_count    ] || (raise ArgumentError)
		output_count     = options[:output_count   ] || (raise ArgumentError)

		raise ArgumentError unless [:first  , :update].include?(@input_mode)
		raise ArgumentError unless [:boolean, :real  ].include?(@output_type)

		# settings
		@has_centered_inputs = @system_settings[:has_centered_inputs] || false

		# inputs/outputs
		@inputs  = Array.new(input_count , 0.0)
		@outputs = Array.new(output_count, (@output_type == :boolean) ? false : 0.0)

		@first_update = true                                        # first update flag
		@running_genes = genome.new_running_genes(@system_settings) # running genes 

		# input genes
		genes        = @running_genes[:environmental]
		@input_genes = genes[0, [@inputs.size, genes.size].min]

		# output genes
		genes         = @running_genes[:behavioural]
		@output_genes = genes[0, [@outputs.size, genes.size].min]

		# cytoplasm
		@cytoplasm = nil
	end # ctor

	# update
	def update
		# inputs
		if (@first_update)
			do_set_inputs
			@first_update = false
		else
			# decay regulatory concentrations
			@running_genes[:regulatory].each{ |gene| gene.decay_concentration }

			# set inputs for each update
			if (@input_mode == :update)
				do_set_inputs
			end
		end

		# aux: debug print protein line
		debug_print_protein_line = lambda do |s, p|
			stream = $stderr
			stream << "#{s} "
			stream <<
				Array.new(15 * 15) do |i|
					v = p[i]
					if v == 0
						'_'
					elsif v < 64
						'-'
					else
						'X'
					end
				end.join
			stream << "\n"
		end

		# aux: debug print protein square
		debug_print_protein_square = lambda do |s, p|
			$stderr <<
				Array.new(15) do |y|
					s +
						Array.new(15) do |x|
							v = p[y * 15 + x]
							if v == 0
								'_'
							elsif v < 64
								'-'
							else
								'X'
							end
						end.join
				end.join("\n") + "\n"
		end 


		# new cytoplasm
		delta = Fgrn::Concentration::ZERO_DELTA

		# - regulatory proteins/concentations
		regulatory_proteins = []
		@running_genes[:regulatory].each{ |g| regulatory_proteins << g.output_protein if g.concentration.abs > delta }

		# - receptor protein
		receptor_gene = @running_genes[:receptor][0]
		receptor_protein = receptor_gene ? receptor_gene.output_protein : nil
#		debug_print_protein_square.call('C ', receptor_protein)
		
		# - environmental proteins/concentations
		environmental_proteins = []
		@running_genes[:environmental].each{ |g| environmental_proteins << g.promoter_protein if g.concentration.abs > delta }
#		environmental_proteins.each{ |e| debug_print_protein_square.call('E ', e) }

#		environmental_proteins.each{ |p| puts "env #{p.concentration}" }

#		$stderr << "--- E(#{environmental_proteins.size}) R(#{regulatory_proteins.size})\n"

		side = 15 # can't reliably get it from anywhere, FIXME
		@cytoplasm = VectorProtein.new_cytoplasm(side * side, regulatory_proteins, receptor_protein, environmental_proteins)
#		debug_print_protein_square.call('CY', @cytoplasm)

		# update regulatory/behavioural genes
		@running_genes[:regulatory ].each{ |gene| gene.update(@cytoplasm) }
		@running_genes[:behavioural].each{ |gene| gene.update(@cytoplasm) }

		# get outputs
		case(@output_type)
		when :boolean; @output_genes.each.with_index{ |g, i| @outputs[i] = g.activated }
		when :real   ; @output_genes.each.with_index{ |g, i| @outputs[i] = g.output }
		end
	end

	def reward(value) ; end
	def signal_failure; end

	# details string
	def details_string
		@running_genes.collect{ |k, a| a.collect{ |g| g.details_string }.join(' ') }.join('  ')
	end

private
	# set inputs
	def do_set_inputs
		@input_genes.each.with_index do |gene, i|
			ci = @has_centered_inputs
			if (ci  && !(-1.0..1.0).include?(@inputs[i])) ||
			 ((!ci) && !( 0.0..1.0).include?(@inputs[i]))
				raise 'Invalid input (index ' + i.to_s + ') : ' + @inputs[i].to_s
			end

			gene.concentration = @inputs[i] * Fgrn::Concentration::SATURATION
		end
	end
end # Fgrn::Controller

