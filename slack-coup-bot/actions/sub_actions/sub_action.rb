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
		end
	end
end