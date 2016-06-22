require 'subactinos'

class PlayAction < Action
	def initialize(player)
		super(player)
		@subactions = []
	end

	def do
		respond evaluate
	end

	def subactions
		[]
	end

	def public_message(result)
		"#{player}'s #{self} has completed"
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

class Exchange < PlayAction
	def subactions
		[PickUp.new(2), Return.new(2, prompt: true)]
	end
end