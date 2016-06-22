require 'sub_actions'

class PlayAction < Action
	def initialize(player)
		super(player)
		@subactions = []
	end

	def validate
	end

	def subactions
		[]
	end

	def public_message(result)
		"#{player}'s #{self} action has completed."
	end
end

class Income < PlayAction
	def subactions
		[GainCoins.new(player, 1)]
	end
end

class ForeignAid < PlayAction
	def subactions
		[GainCoins.new(player, 2)]
	end
end

class Tax < PlayAction
	def subactions
		[GainCoins.new(player, 3)]
	end
end

class Exchange < PlayAction
	def subactions
		cards_to_exchange = player.remaining_cards
		[PickUp.new(cards_to_exchange), Return.new(cards_to_exchange, prompt: true)]
	end
end