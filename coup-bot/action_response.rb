class ActionResponse
	attr_reader :user
	attr_reader :result
	attr_reader :public_message
	attr_reader :private_message
	attr_reader :new_actions

	def initialize(user, result, public_message, private_message, new_actions)
		@user = user
		@result = result
		@public_message = public_message
		@private_message = private_message
		@new_actions = new_actions
	end
end