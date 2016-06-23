require 'actions/play_actions'

module SlackCoupBot
	module Actions

		class Cancel
			attr_reader :action
			def initialize(action)
				@action = action
			end

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
				Cancel.new(action)
			end
		end

		class Block < Reaction
			def validate
				if ! action.blockable?
					raise ValidationError, "Cannot block #{action}"
				end
			end
		end

		class Challenge < Reaction
			def subactions
				[Flip.new(action.player, prompt: respond(message: "#{player} has challenged your #{action} action, #{action.player}. You must flip a card."))]
			end

			def validate
				if ! action.challengable?
					raise ValidationError, "Cannot challenge #{action}"
				end
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
					result = Cancel.new(action)
				else
					# Challenge failed. Challenger must flip, and challengee will exchange their flipped card
					message = "Challenge failed! #{action.player} has the #{card} card!"
					new_actions = [Flip.new(player, prompt: respond(message: "You must flip a card, #{player}")), Return.new(target, card), Pickup.new(target, 1)]
					result = nil
				end

				respond result: result, message: message, new_actions: new_actions
			end
		end
	end
end