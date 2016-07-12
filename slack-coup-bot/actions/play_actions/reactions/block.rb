require 'actions/play_actions/reactions/reaction'

module SlackCoupBot
	module Actions
		class Block < Reaction
			def validate
				super
				if action.is_a? TargetedAction
					if player != action.target
						raise ValidationError, "Only #{action.target} can #{self} this action"
					end
				end
				if ! action.blockable?
					raise ValidationError, "#{action} cannot be blocked."
				end
			end

			def self.desc
				"Block another player's action."
			end
			def self.long_desc
				"Block the most recent action. Any block can be challenged if a player does not believe you have the required card."
			end
		end
	end
end