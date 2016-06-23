require 'actions/play_actions'
require 'actions/sub_actions'
require 'errors'

module SlackCoupBot
	module Actions
		class TargetedAction < PlayAction
			attr_reader :target

			def initialize(player, target)
				super(player)
				@target = target
			end

			def validate
				if player == target
					raise ValidationError, "You cannot #{self} yourself, #{player}"
				end
			end
		end

		class Steal < TargetedAction
			def subactions
				[LoseCoins.new(target, 2), GainCoins.new(player)]
			end

			def validate
				super
				if target.coins < 1
					raise ValidationError, "You cannot steal from #{target} - they have no coins."
				end
			end
		end

		class Assassinate < TargetedAction
			def subactions
				[Flip.new(target, prompt: "#{player} has assassinated you, #{target}. You must flip a card.")]
			end

			def validate
				super
				if player.coins < 3
					raise ValidationError, "You cannot assassinate - three coins are required. You only have #{player.coins} coin(s)."
				end
				if target.remaining_cards.count < 1
					raise ValidationError, "You cannot assassinate #{target} - they are out of the game."
				end
			end
		end

		class Coup < TargetedAction
			def subactions
				[Flip.new(target, prompt: "#{player} has couped you, #{target}. You must flip a card.")]
			end

			def validate
				super
				if player.coins < 7
					raise ValidationError, "You cannot coup - seven coins are required. You only have #{player.coins} coin(s)."
				end
				if target.remaining_cards.count < 1
					raise ValidationError, "You cannot coup #{target} - they are out of the game."
				end
			end
		end
	end
end