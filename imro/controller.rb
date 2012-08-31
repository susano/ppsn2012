require 'imro/imro'
require 'imro/mpp'

class Imro::Controller

	attr_writer :inputs
	attr_reader :outputs

	# ctor
	def initialize(options)
		@genome        = options[:genome        ] || (raise ArgumentError)
		@output_type   = options[:output_type   ] || (raise ArgumentError)
		mpp_definition = options[:mpp_definition] || (raise ArgumentError)

		# input/output count
		@input_count    = @genome.input_genes.size
		@output_count   = @genome.output_genes.size

		# input/output arrays
		@inputs  = Array.new(@input_count , 0.0)
		@outputs = Array.new(@output_count, 0.0)

		# genes
		@input_genes      = @genome.input_genes
		@output_genes     = @genome.output_genes
		@regulatory_genes = @genome.regulatory_genes

		# mpp
		@mpp = Imro::Mpp.new(mpp_definition.merge(
#			:input_count  => @input_count,
			:output_count => @output_count))

		# debug: print genome
#		$stdout << "debug genome:\n"
#		genome_string = @genome.to_s
#		genome_string.each_line{ |line| $stdout << "debug #{line}" }
	end

	# update
	# TRY with regulatory before output
	def update
#		$stdout << "debug mpp:\n"
#		mpp_string = @mpp.to_s
#		mpp_string.each_line{ |line| $stdout << "debug mpp #{line}" }
#		$stdout << "\n"
		
#		$stderr << "debug update begin \n"
		@mpp.age!

		# set inputs
#		@mpp.inputs = Array.new(@input_count){ |i| @input_genes[i].output(@inputs[i]) }

		@input_count.times{ |i| @mpp.add_protein(@input_genes[i].output(@inputs[i])) }
	
		# state
		state = @mpp.state


		# get outputs
		@output_count.times do |i|
			@outputs[i] = @output_genes[i].output(state, @output_type)
		end

		# regulate
		@regulatory_genes.each do |g|
			protein = g.output(state)
			@mpp.add_protein(protein) if protein
		end
		# debug: update
#		$stdout << "debug update I: #{@input_vector.collect{ |v| ("%.2f" % v).rjust(5) }.join(' ')}  O: #{@outputs.collect{ |s| ("%.2f" % s).rjust(5) }.join(' ')}\n"
	end

	def reward(v)     ; end # reward
	def signal_failure; end # signal failure
end # Imro::Controller

