require 'errors'

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
		card = @game.deck.shift
		@cards.push card
		card
	end

	def lose_card(card)
		card_index = @cards.index_of card
		if card_index
			card = @cards.delete_at card_index
			card.hide
			@game.deck.push card
			@game.deck.shuffle
			card
		else
			nil
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
		@user.name
	end
end