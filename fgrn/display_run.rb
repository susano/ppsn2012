require 'fgrn/fgrn'
require 'fgrn/concentration'
require 'utils/assert'

class Fgrn::DisplayRun

	# ctor
	def initialize(options = {})
		@states = []
	end

	# add controller state
	def add_controller_state(controller)

		cytoplasm     = controller.cytoplasm.make_clone
		running_genes = controller.running_genes

		# environmental genes
		environmental_genes =
			running_genes[:environmental].collect do |g|
				{
					:concentration => g.concentration,
					:in_cytoplasm  => in_cytoplasm?(g.promoter_protein, g.concentration, cytoplasm)
				}
			end

		# regulatory genes
		previous_state = @states[-1]
		previous_regulatory_genes = previous_state ? previous_state[:regulatory_genes] : nil
		regulatory_genes = 
 			running_genes[:regulatory].collect.with_index do |g, i|
				previous_concentration = Fgrn::Concentration.decay(previous_regulatory_genes ?  previous_regulatory_genes[i][:concentration] : 0.0, 0.8, 0.2)
				{
					:previous_concentration => previous_concentration,
					:previous_in_cytoplasm  => in_cytoplasm?(g.output_protein, previous_concentration, cytoplasm),
					:concentration          => g.concentration,
					:activated              => g.activated
 				}
			end

		# behavioural genes
		behavioural_genes =
			running_genes[:behavioural].collect do |g|
				{
					:activated => g.activated
				}
			end

		# current state
		state = {
			:cytoplasm           => cytoplasm,
			:environmental_genes => environmental_genes,
			:regulatory_genes    => regulatory_genes,
			:behavioural_genes   => behavioural_genes
		}

		@states << state
	end

	# to pgm
	def to_pgm(options)
		row_height  = options[:row_height ] || (raise ArgumentError)
		cell_width  = options[:cell_width ] || (raise ArgumentError)
		level_count = options[:level_count] || (raise ArgumentError)
		first_state = @states[0]

		environmental_count = first_state[:environmental_genes].size
		regulatory_count    = first_state[:regulatory_genes   ].size
		behavioural_count   = first_state[:behavioural_genes  ].size

		gene_count = environmental_count + regulatory_count + behavioural_count

		width  = gene_count   * cell_width
		height = @states.size * row_height

		saturation = Fgrn::Concentration::SATURATION.to_i

		result_string = "P2\n#{width} #{height}\n#{level_count}\n"
		@states.each do |s|
			cells = []
			[:environmental_genes, :regulatory_genes, :behavioural_genes].each do |type|
				cells += s[type].collect do |h|
					c = h[:concentration]
					a = h[:activated    ]
					if c then c.to_i * level_count / saturation
					else      a ? level_count : 0
					end
				end # collect
			end # each type 

			line = ''
			cells.each do |v|
				cell_width.times do
					line << "#{v} "
				end
				line += "\n"
			end

			row_height.times do
				result_string << line
			end
		end # @states.each

		result_string
	end # to_pgm

	# to ppm
	def to_ppm(options)
		row_height           = options[:row_height          ] || (raise ArgumentError)
		cell_width           = options[:cell_width          ] || (raise ArgumentError)
		cytoplasm_cell_width = options[:cytoplasm_cell_width] || (raise ArgumentError)
		gene_margin          = options[:gene_margin         ] || (raise ArgumentError)
		category_margin      = options[:category_margin     ] || (raise ArgumentError)

		# gene counts
		first_state = @states[0]
		environmental_count = first_state[:environmental_genes].size
		regulatory_count    = first_state[:regulatory_genes   ].size
		behavioural_count   = first_state[:behavioural_genes  ].size
		cytoplasm_size      = first_state[:cytoplasm].size

		# colors
		# aux: color string from rgb values
		color_string_rgb = lambda do |r, g, b|
			"#{r} #{g} #{b}"
		end
		max_color_value = 255
		color_white = color_string_rgb.call(max_color_value, max_color_value, max_color_value)

		environmental_background = color_string_rgb.call(255, 192, 127)
		regulatory_background    = color_string_rgb.call(127, 255, 192)
		cytoplasm_background     = color_string_rgb.call(127, 192, 255)
		behavioural_background   = color_string_rgb.call(192, 127, 255)

		# width/height
		# - aux: gene type cells column width
		gene_type_cell_column_width = lambda do |count|
			count * cell_width + (count - 1) * gene_margin
		end

		# - width
		width =
			gene_type_cell_column_width.call(environmental_count) +
			gene_type_cell_column_width.call(regulatory_count   ) +
			cytoplasm_size * cytoplasm_cell_width                 +
			gene_type_cell_column_width.call(regulatory_count   ) +
			gene_type_cell_column_width.call(behavioural_count  ) +
			10 * category_margin 

		# - height
		height = @states.size * row_height

		# saturation
		saturation = Fgrn::Concentration::SATURATION.to_i

		# aux: output a margin
		output_margin = lambda do |width|
			Array.new(width, @ppm_background_color).join(' ')
		end

		# aux: output a gene concentration cell
		output_concentration_cell = lambda do |concentration, in_cytoplasm|

			value = (concentration * max_color_value / saturation).to_i
			assert{ (0..max_color_value).include?(value) }
			color = in_cytoplasm ?
				color_string_rgb.call(    0,     0, value) :
				color_string_rgb.call(value, value, value)

			Array.new(cell_width, color).join(' ')
		end

		# aux: output a gene activation cell
		output_activation_cell = lambda do |activated|
			value = activated ? max_color_value : 0
			color = color_string_rgb.call(value, value, value)
			Array.new(cell_width, color).join(' ')
		end

		# ppm header
		result_string = "P3\n#{width} #{height}\n#{max_color_value}\n"
		@states.each do |s|
			result_line = ''
			
			# environmental genes: concentration
			@ppm_background_color = color_string_rgb.call(255, 192, 127)
			result_line << " #{output_margin.call(category_margin)} "
			result_line << s[:environmental_genes].collect do |h|
				output_concentration_cell.call(h[:concentration], h[:in_cytoplasm])
			end.join(" #{output_margin.call(gene_margin)} ")
			result_line << " #{output_margin.call(category_margin)} "

			# regulatory genes: concentration
#			@ppm_background_color = color_string_rgb.call(126, 255, 192)
			result_line << " #{output_margin.call(category_margin)} "
			result_line << s[:regulatory_genes].collect do |h|
				output_concentration_cell.call(h[:previous_concentration], h[:previous_in_cytoplasm])
			end.join(" #{output_margin.call(gene_margin)} ")
			result_line << " #{output_margin.call(category_margin)} "

			# cytoplasm
#			@ppm_background_color = color_string_rgb.call(127, 192, 255)
			result_line << " #{output_margin.call(category_margin)} "
			cytoplasm = s[:cytoplasm]
			result_line << Array.new(cytoplasm.size) do |i|
				value = (cytoplasm[i] * max_color_value / 127).to_i
				assert{ (0..max_color_value).include?(value) }
				Array.new(cytoplasm_cell_width, color_string_rgb.call(value, value, value)).join(' ')
			end.join(' ')
			result_line << " #{output_margin.call(category_margin)} "
			
			# regulatory genes: activation
#			@ppm_background_color = color_string_rgb.call(126, 255, 192)
			result_line << " #{output_margin.call(category_margin)} "
			result_line << s[:regulatory_genes].collect do |h|
				output_activation_cell.call(h[:activated])
			end.join(" #{output_margin.call(gene_margin)} ")
			result_line << " #{output_margin.call(category_margin)} "
	
			# behavioul genes: activation
#			@ppm_background_color = color_string_rgb.call(192, 127, 255)
			result_line << " #{output_margin.call(category_margin)} "
			result_line << s[:behavioural_genes].collect do |h|
				output_activation_cell.call(h[:activated])
			end.join(" #{output_margin.call(gene_margin)} ")
			result_line << " #{output_margin.call(category_margin)} "
	
			result_line << "\n"

			row_height.times do result_string << result_line end
		end # @states.each

		result_string
	end # to_ppm

private
	# is the protein in that concentration in this cytoplasm?
	def in_cytoplasm?(protein, concentration, cytoplasm)
#		$stderr << ">>> in_cytoplasm?\n"

		return false if concentration == 0.0

		cytoplasm_concentration = cytoplasm.concentration

		protein.size.times do |i|
			v = protein[i]

#			$stderr << " -  v = #{v}, cytoplasm[i] = #{cytoplasm[i]}\n"
#			return true if v != 0 && v == cytoplasm[i] && (cytoplasm_concentration[i] - concentration).abs < 0.001
			return true if v != 0 && v == cytoplasm[i]
		end

		return false
	end
end # Fgrn::DisplayRun

