require 'actions/play_actions/targeted_action'
require 'actions/cancel'

module SlackCoupBot
	module Actions
		class Reaction < TargetedAction
			attr_reader :action

			def initialize(player, action)
				super(player, action.player)
				@action = action
				@target = action.player
			end

			def public_message(result)
				"#{player}'s #{self} succeeds!"
			end

			def evaluate(*args)
				Cancel.new(action)
			end
		end
	end
end