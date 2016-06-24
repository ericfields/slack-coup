require 'actions/play_actions/reactions/reaction'

module SlackCoupBot
	module Actions
		class Block < Reaction
			def validate
				super
				if ! action.blockable?
					raise ValidationError, "#{action} cannot be blocked."
				end
			end
		end
	end
end