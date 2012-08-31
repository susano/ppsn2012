import 'org.jruby.Ruby'
import 'org.jruby.RubyArray'
import 'org.jruby.RubyNumeric'

import 'fgrn.ProteinConcentration'

class VectorProtein

	# FIX replace by attr_reader macro, once macros work
	def data():int[]
		@data
	end

	def concentration():ProteinConcentration
		@concentration
	end

	def difference():int
		@difference
	end

	def mean_concentration():double
		@mean_concentration
	end

	# merge proteins, including their concentration
	def self.merge_proteins(proteins:RubyArray):VectorProtein
		raise IllegalArgumentException if proteins.isEmpty

		protein_count = proteins.size
		if protein_count == 1
			VectorProtein(proteins.get(0)).make_clone
		else
			size = VectorProtein(proteins.get(0)).data.length

			new_data          = int[   size]
			new_concentration = double[size]

			size.times do |i|
				max_value         = 0
				max_concentration = 0.0
				
				protein_count.times do |j|
					p = VectorProtein(proteins.get(j))
					v = p.data[i]
					if v > max_value
						max_value         = v
						max_concentration = p.concentration[i]
					end
				end

				new_data[i]          = max_value
				new_concentration[i] = max_concentration
			end

			self.new(new_data, true, ProteinConcentration.new(size, 0.0, new_concentration))
		end
	end

	# ctor
	def self.new_from_ruby(data:RubyArray)
		runtime = data.getRuntime
		length = data.size
		d = int[length]
		length.times{ |i| d[i] = RubyNumeric.fix2int(data.aref(RubyNumeric.int2fix(runtime, i))) }
	
		self.new(d, true, ProteinConcentration.new(length, 0.0, nil))
	end

	# new cytoplasm
	def self.new_cytoplasm(size:int, regulatory_proteins:RubyArray, receptor_protein:VectorProtein, environmental_proteins:RubyArray):VectorProtein
		runtime = regulatory_proteins.getRuntime()
		regulatory_count = regulatory_proteins.size 
		all = RubyArray.newArray(runtime, regulatory_count + 1)
		regulatory_count.times do |i|
			all.set(i, regulatory_proteins.get(i))
		end

		if !environmental_proteins.isEmpty
			merged_environmnental = VectorProtein.merge_proteins(environmental_proteins)
			merged_environmnental.mask!(receptor_protein) if receptor_protein
			all.set(regulatory_count, merged_environmnental)
		end

		all.isEmpty ? VectorProtein.new_black_protein(size) : VectorProtein.merge_proteins(all)
	end

	# new black protein
	def self.new_black_protein(length:int):VectorProtein
		data = int[length]
		length.times{ |i| data[i] = 0 }

		VectorProtein.new(data, true, ProteinConcentration(nil))
	end

	# ctor
	def initialize(data:int[], owned:boolean, concentration:ProteinConcentration)
		@data          = data
		@owned         = owned
		@concentration = (concentration != nil) ? concentration : ProteinConcentration.new(data.length, 0.0, nil)

		@difference         = 0
		@mean_concentration = 0.0
	end

	# clone
	def make_clone():VectorProtein
		length = @data.length
		data = int[length]
		length.times do |i|
				data[i] = @data[i]
		end

		VectorProtein.new(data, true, @concentration.make_clone)
	end

	# size
	def size:int
		@data.length
	end

	# at
	def [](index:int):int
		@data[index]
	end

	# mask
	def mask!(protein_mask:VectorProtein)
		length = @data.length

		if !@owned
			data = int[length]
			length.times{ |i| data[i] = @data[i] }
			@data = data
			@owned = true
		end

		mask_data = protein_mask.data
		length.times do |i|
			@data[i] = 0 if mask_data[i] == 0
		end

		self
	end

	# difference to promoter
	def difference_to_promoter(promoter_protein:VectorProtein):void
		difference        = 0
		non_black_count   = 0
		concentration_sum = 0.0

		data          = @data
		promoter_data = promoter_protein.data
		concentration = @concentration

		data.length.times do |i|
			promoter_value = promoter_data[i]
			if promoter_value != 0
				difference        += Math.abs(data[i] - promoter_value)
				non_black_count   += 1
				concentration_sum += concentration[i]
			end
		end

		mean_concentration = ((non_black_count == 0) ? 0.0 : double(concentration_sum) / double(non_black_count))

		@difference         = difference 
		@mean_concentration = mean_concentration
	end
end # VectorProtein

