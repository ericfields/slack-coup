require 'actions/sub_actions/sub_action'

module SlackCoupBot
	module Actions
		class PickUp < SubAction
			def initialize(player, count = nil)
				super(player)
				@count = count
			end

			def evaluate(count = nil)
				@count ||= (count.is_a?(Enumerable) ? count.count : count)
				cards = []
				@count.times do
					cards << @player.gain_card
				end
				cards
			end

			def public_message(cards)
				"#{player} picked up #{cards.count} card(s)"
			end

			def private_message(cards)
				"You picked up the #{cards} card(s).\nYou now have the #{player.cards} card(s)"
			end
		end
	end
end