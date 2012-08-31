import 'fgrn.MondrianPortion'
import 'fgrn.ProteinConcentration'
import 'fgrn.VectorProtein'
import 'org.jruby.RubyArray'
import 'org.jruby.RubyNumeric'

class MondrianProteinFactory

#	OPERATOR_MIN = 0
#	OPERATOR_MAX = 1

	# new mondrian protein
	def self.new_mondrian_protein(
		protein_side:int,
		direction:int,
		position:int,
		value1:int,
		value2:int,
		black_position:int):VectorProtein

		VectorProtein.new(MondrianPortion.new(protein_side, direction, position, value1, value2, black_position).data, true, ProteinConcentration(nil))
	end

	# new mondrian protein min
	def self.new_mondrian_protein_min(side:int, operands:RubyArray):VectorProtein
		new_mondrian_protein_operator(side, operands, 0)
	end

	# new mondrian protein max
	def self.new_mondrian_protein_max(side:int, operands:RubyArray):VectorProtein
		new_mondrian_protein_operator(side, operands, 1)
	end

	# new mondrian protein operator
	def self.new_mondrian_protein_operator(side:int, operands:RubyArray, operator:int):VectorProtein
		protein_length = side * side

		operand_count = operands.size()

		if operand_count == 0
			VectorProtein.new_black_protein(protein_length)
		else # merging one or several mondrian portions
			data = int[protein_length]

			# convert operand definitions to portions
			runtime = operands.getRuntime()
			context = runtime.getCurrentContext()
			portions = MondrianPortion[operand_count]
			operand_count.times do |i|
				o = operands.aref(RubyNumeric.int2fix(runtime, i))
				portions[i] = MondrianPortion.new(
					side,
					RubyNumeric.fix2int(o.callMethod(context, 'direction')),
					RubyNumeric.fix2int(o.callMethod(context, 'position')),
					RubyNumeric.fix2int(o.callMethod(context, 'value1')),
					RubyNumeric.fix2int(o.callMethod(context, 'value2')),
					RubyNumeric.fix2int(o.callMethod(context, 'black_position')))
			end

			# set initial data value to first operand
			first_portion_data = portions[0].data
			protein_length.times do |i|
				data[i] = first_portion_data[i]
			end

			if operator == 0
				(operand_count - 1).times do |oi|
					op_data = portions[oi + 1].data

					protein_length.times do |i|
						v = op_data[i]
						data[i] = v if v < data[i]
					end
				end
			elsif operator == 1
				(operand_count - 1).times do |oi|
					op_data = portions[oi + 1].data

					protein_length.times do |i|
						v = op_data[i]
						data[i] = v if v > data[i]
					end
				end

			else
				raise IllegalArgumentException
			end

			VectorProtein.new(data, true, ProteinConcentration(nil))
		end
	end
end # MondrianProteinFactory

