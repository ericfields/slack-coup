require 'action_response'

class Action
	attr_reader :player

	def initialize(player)
		@player = player
	end

	def respond(result, message: nil, private: nil, new_actions: [])
		ActionResponse.new(result, 
			message || public_message(result), 
			private || private_message(result), 
			new_actions)
	end

	def public_message(result)
	end

	def private_message(result)
	end

	def to_s
		self.class.name.downcase
	end
end