require 'errors'

class TargetedAction < PlayAction
	attr_reader :target

	def initialize(player, target)
		super(player)
		@target = target
	end

	def validate
	end
end

class Steal < TargetedAction
	def subactions
		[LoseCoins.new(target, 2), GainCoins.new(player, 2)]
	end

	def validate
		if player.coins < 2
			raise ValidationError, "You cannot steal - two coins are required. You only have #{player.coins} coin(s)."
		end
		if target.coins < 1
			raise ValidationError, "You cannot steal from #{target} - they have no coins."
		end
	end
end

class Assassinate < TargetedAction
	def subactions
		[Flip.new(target)]
	end

	def validate
		if target.cards.count{|c| ! c.flipped? } < 1
			raise ValidationError, "You cannot assassinate #{target} - they are out of the game."
		end
	end
end

class Coup < TargetedAction
	def subactions
		[Flip.new(target)]
	end
end