require 'actions/play_actions/play_action'

module SlackCoupBot
	module Actions
		class Exchange < PlayAction
			def subactions
				cards_to_exchange = player.remaining_cards.count
				[PickUp.new(player, cards_to_exchange), Return.new(player, cards_to_exchange, 
					private_prompt: "Return #{cards_to_exchange} card(s) to the deck with `return #{cards_to_exchange > 1 ? '<card1> <card2>' : '<card>'}`")]
			end
		end
	end
end