require 'actions/play_actions'

module SlackCoupBot
	module Actions

		class Cancel
			def to_s
				"cancellation"
			end
		end

		class Reaction < TargetedAction
			attr_reader :action

			def initialize(player, action)
				super(player, action.player)
				@action = action
			end

			def public_message(result)
				"#{player}'s #{self} succeeds!"
			end

			def evaluate
				Cancel.new
			end
		end

		class Block < Reaction
			
		end

		class Challenge < Reaction
			def subactions
				[Flip.new(action.player)]
			end

			def evaluate(card)
				if action.is_a?(Block) && ! action.blockers.include?(card.class)
					false
				elsif ! action.actors.include?(card.class)
					false
				else
					true
				end
			end

			def do(card)
				succeeded = evaluate card
				if succeeded
					message = "Challenge succeeded! #{action.player} has lost the #{card} card."
					new_actions = []
					result = Cancel.new
				else
					# Challenge failed. Challenger must flip, and challengee will exchange their flipped card
					message = "Challenge failed! #{player} must flip a card."
					new_actions = [Flip.new(player), Return.new(target, card, prompt: false), Pickup.new(target, 1, prompt: false)]
					result = nil
				end

				respond result, message: message, new_actions: new_actions
			end
		end
	end
end