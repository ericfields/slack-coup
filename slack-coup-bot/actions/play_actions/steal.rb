require 'actions/play_actions/targeted_action'

module SlackCoupBot
	module Actions
		class Steal < TargetedAction
			def subactions
				[LoseCoins.new(target, 2), GainCoins.new(player)]
			end

			def validate
				super
				if target.coins < 1
					raise ValidationError, "You cannot steal from #{target} - they have no coins."
				end
			end

			def desc
				"#{to_s} from"
			end
		end
	end
end