require 'actions/play_actions/reactions/reaction'

module SlackCoupBot
	module Actions
		class Challenge < Reaction
			def subactions
				[Flip.new(action.player, prompt: "#{player} has challenged your #{action} action, #{action.player}. You must flip a card by calling `flip <card>`.")]
			end

			def validate
				super
				if ! action.challengable?
					raise ValidationError, "Cannot challenge #{action}"
				end
			end

			def evaluate(card)
				if action.is_a?(Block)
					if card.blocks?(action.action)
						return false
					end
				elsif card.performs?(action)
					return false
				end
				true
			end

			def do(card)
				succeeded = evaluate card
				if succeeded
					message = "Challenge succeeded! #{action.player} has lost the #{card} card."
					new_actions = []
					result = Cancel.new(action)
				else
					# Challenge failed. Challenger must flip, and challengee will exchange their flipped card
					message = "Challenge failed! #{action.player} has the #{card} card!"
					new_actions = [Flip.new(player, prompt: "You must flip a card, #{player}. Flip a card by calling `flip <card>`."), Return.new(target, card), PickUp.new(target, 1)]
					result = nil
				end

				respond result: result, message: message, new_actions: new_actions
			end

			def self.desc
				"Challenge another player's action."
			end

			def self.long_desc
				"Challenge another player's action or block.\n" +
				"You can challenge an action/block if you do not believe that player has the required card.\n" +
				"The challenged a player must flip a card; if the card cannot perform the action, the player loses the card.\n" +
				"If the card can perform the action however, you must flip a card, and the player exchanges their flipped card for a new one."
			end
		end
	end
end