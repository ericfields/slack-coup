class ActionResponse
	attr_reader :result
	attr_reader :public_message
	attr_reader :private_message
	attr_reader :new_actions

	def initialize(result, public_message, private_message, new_actions)
		@result = result
		@public_message = public_message
		@private_message = private_message
		@new_actions = new_actions
	end
end