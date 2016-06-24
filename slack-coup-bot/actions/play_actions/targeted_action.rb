require 'actions/play_actions/play_action'

module SlackCoupBot
	module Actions
		class TargetedAction < PlayAction
			attr_reader :target

			def initialize(player, target)
				super(player)
				@target = target
			end

			def validate
				if player == target
					raise ValidationError, "You cannot #{self} yourself, #{player}"
				end
			end
		end
	end
end