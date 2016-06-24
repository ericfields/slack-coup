require 'actions/sub_actions/sub_action'

module SlackCoupBot
	module Actions
		class Flip < SubAction
			def validate(*cards)
				if cards.count < 1
					raise ValidationError, "You must flip at least one card"
				elsif cards.count > 1
					raise ValidationError, "Cannot flip #{cards}. You must flip one card only."
				end
				card = cards.first
				if ! player.has_cards? card
					raise ValidationError, "You do not have the #{card} card."
				end
			end

			def evaluate(card)
				player.flip_card card
			end

			def public_message(card)
				"#{player} revealed the #{card} card!"
			end
		end
	end
end