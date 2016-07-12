require 'actions/action'

module SlackCoupBot
	module Actions
		class SubAction < Action
			attr_reader :prompt

			def initialize(player, *params, prompt: nil, private_prompt: nil)
				super(player)
				if prompt || private_prompt
					@prompt = Response.new(player.user, nil, prompt, private_prompt, nil)
				end
			end

			def public_message
			end

			def ==(other)
				other.class == self.class && other.player == player
			end

			class << self
				def desc
					"#{self} is only performed as a response to another action."
				end
			end
		end
	end
end