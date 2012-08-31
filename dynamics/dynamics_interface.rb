
class DynamicsInterface
	def initial_state              ; raise NotImplementedError; end
	def step_acceleration(t, state); raise NotImplementedError; end

	def post_process(state) 
		state
	end
end # DynamicsInterface

