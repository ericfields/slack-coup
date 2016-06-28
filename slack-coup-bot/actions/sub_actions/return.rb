require 'actions/sub_actions/sub_action'

module SlackCoupBot
	module Actions
		class Return < SubAction
			attr_reader :cards

			def initialize(player, *cards, **options)
				super(player, **options)
				if cards.first.is_a? Numeric
					@cards = Array.new(cards.first)
				else
					@cards = cards
				end
			end

			def validate(*cards)
				cards.each do |card|
					if ! player.has_cards? card
						raise ValidationError, "You do not have the #{card} card"
					end
				end
			end

			def evaluate(*cards)
				@cards = cards if !@cards.any?
				@cards.collect do |card|
					@player.lose_card card
				end
			end

			def public_message(cards)
				"#{player} returned #{cards.count} card(s) to the deck"
			end

			def private_message(cards)
				"You returned the #{cards} card(s) to the deck.\nYou now have the #{player.cards} cards"
			end

			def ==(other)
				super(other) && other.cards.count == cards.count
			end
		end
	end
end