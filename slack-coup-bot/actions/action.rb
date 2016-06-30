require 'actions/response'
require 'errors'

module SlackCoupBot
	module Actions
		class Action
			attr_reader :player

			def initialize(player)
				@player = player
				@logger = SlackRubyBot::Client.logger
			end

			def respond(result: nil, message: nil, private: nil, new_actions: [])
				Response.new(player.user, 
					result,
					message || public_message(result), 
					private || private_message(result), 
					new_actions)
			end

			def validate
			end

			def do(*args)
				respond result: evaluate(*args)
			end

			def evaluate(*args)
			end

			def public_message(result)
			end

			def private_message(result)
			end

			def ==(other_action)
				self.class == other_action.class
			end

			class << self
				def to_s
					"`#{self.name.split('::').last.downcase}`"
				end

				def verb
					to_s
				end
			end

			delegate :to_s, :verb, to: "self.class"
		end
	end
end