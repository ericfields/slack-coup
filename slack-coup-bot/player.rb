require 'errors'

module SlackCoupBot
	class Player
		attr_reader :user
		attr_reader :cards
		attr_reader :coins

		def initialize(game, user)
			@game = game
			@user = user

			@cards = []
			@coins = 0

			@eliminated = false 
		end

		def gain_coins(amount)
			@coins += amount
			amount
		end

		def lose_coins(amount)
			if @coins == 0
				raise ValidationError, "target does not have any coins"
			elsif @coins < amount
				amount = @coins
			end
			@coins -= amount
			amount
		end

		def gain_card
			card = @game.take_from_deck
			@cards.push card
			card
		end

		def lose_card(card)
			card_index = @cards.index card
			if card_index
				card = @cards.delete_at card_index
				@game.return_to_deck card
				card
			else
				raise InternalError, "#{self} is trying to lose the #{card} card but #{self} does not have that card"
			end
		end

		def has_cards?(*cards)
			unmatched_cards = cards.clone
			remaining_cards.each do |card|
				card_index = unmatched_cards.index card
				unmatched_cards.delete_at(card_index) if card_index
			end
			unmatched_cards.empty?
		end

		def flip_card(card)
			@cards.find{|c| c == card}.flip
		end

		def remaining_cards
			@cards.select{|c| ! c.flipped? }
		end

		def flipped_cards
			@cards.select{|c| c.flipped? }
		end

		def eliminate
			@eliminated = true
		end

		def eliminated?
			@eliminated
		end

		def ==(other_player)
			other_player.user.id == self.user.id
		end

		def to_s
			"*#{@user.name}*"
		end
	end
end