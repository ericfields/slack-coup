require 'errors'

class Player
	attr_reader :id
	attr_reader :name
	attr_reader :cards
	attr_reader :coins

	def initialize(game, id, name)
		@game = game
		@id = id
		@name = name

		@cards = []
		@max_cards = 2

		@coins = 0
	end

	def gain_coins(amount)
		@coins += amount
		amount
	end

	def lose_coins(amount)
		if @coins == 0
			raise PlayerError, "target does not have any coins"
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

	def lose_card
		card = @cards.delete
		@game.deck.push card
		@game.deck.shuffle
		card
	end

	def flip_card(card)
		card.flip
	end

	def to_s
		@name
	end
end