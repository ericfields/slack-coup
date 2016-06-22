require 'actions'

class SubAction < Action
	attr_reader :params

	def initialize(player, prompt: true, params: nil)
		super(player)
		@prompt = prompt
		@params = params
	end

	def do
		result = evaluate
		respond message: public_message(result)
	end

	def prompt?
		@prompt
	end

	def ==(other)
		other.class == self.class && other.player == player
	end
end

class GainCoins < SubAction
	def initialize(player, count)
		super(player, prompt: false)
		@count = count
	end

	def public_message(result)
		"#{player} has gained "
	end

	def evaluate
		@player.gain_coins @count
	end
end

class LoseCoins < SubAction
	def initialize(player, count)
		super(player, prompt: false)
		@count = count
	end

	def evaluate
		result = @player.lose_coins @count
		respond result: result
	end
end

class PickUp < SubAction
	def initialize(player, count)
		super(player, prompt: false)
		@count = count
	end

	def evaluate
		cards = (1..@count).collect do
			@player.gain_card
		end
		respond result: cards,
			message: "#{player} picked up #{cards.count} card(s)",
			private: "You picked up the #{cards} card(s)"
	end
end

class Return < SubAction
	attr_reader :cards

	def initialize(player, cards, prompt: true)
		super(player, prompt: prompt)
		if cards.is_a? Number
			@cards = Array.new(cards)
		else
			@cards = cards
		end
	end

	def validate(*cards)
		if ! player.has_cards? *cards
			raise ValidationError, "You do not have the #{cards} card(s)"
		end
	end

	def evaluate(*cards)
		@cards = cards if @cards.empty?
		@cards.collect do |card|
			@player.lose_card card
		end
	end

	def ==(other)
		super(other) && other.cards.count == cards.count
	end
end

class Flip < SubAction
	def initialize(player)
		super(player, prompt: true)
	end

	def validate(card)
		player.has_cards? card
	end

	def evaluate(card)
		player.flip_card card
	end
end