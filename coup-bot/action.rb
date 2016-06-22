require 'action_response'
require 'cards'

class Action
	attr_reader :player

	def initialize(player)
		@player = player
	end

	def respond(result, message: nil, private: nil, new_actions: [])
		ActionResponse.new(player.user, 
			result,
			message || public_message(result), 
			private || private_message(result), 
			new_actions)
	end

	def blockable?
		! Card.blockers(self.class).empty?
	end

	def challengable?
		! Card.actors(self.class).empty?
	end

	def do(*args)
		respond evaluate(*args)
	end

	def evaluate(*args)
	end

	def public_message(result)
	end

	def private_message(result)
	end

	def to_s
		self.class.name.downcase
	end
end