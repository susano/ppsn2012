
class IntegratorInterface
	def init(dynamics)   ; raise NotImplementedError end
	def next_state(state); raise NotImplementedError end
end # IntegratorInterface

