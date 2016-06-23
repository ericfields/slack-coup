require 'actions/response'
require 'cards'

module SlackCoupBot
	module Actions
		class Action
			attr_reader :player

			def initialize(player)
				@player = player
			end

			def respond(result, message: nil, private: nil, new_actions: [])
				Response.new(player.user, 
					result,
					message || public_message(result), 
					private || private_message(result), 
					new_actions)
			end

			def blockable?
				! Cards::Card.blockers(self.class).empty?
			end

			def challengable?
				! Cards::Card.actors(self.class).empty?
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
				self.class.name.split('::').last.downcase
			end

			def ==(other_action)
				self.class == other_action.class
			end
		end
	end
end