require 'actions/play_actions/targeted_action'

module SlackCoupBot
	module Actions
		class Coup < TargetedAction
			def subactions
				[
					LoseCoins.new(player, 7),
					Flip.new(target, prompt: "#{player} has couped you, #{target}. You must flip a card by calling `flip <card>`.")
				]
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

			def self.desc
				"Costs 7 coins. Target a player to lose a card."
			end
		end
	end
end