require 'actions/play_actions/targeted_action'

module SlackCoupBot
	module Actions
		class Assassinate < TargetedAction
			def subactions
				[
					LoseCoins.new(player, 3),
					Flip.new(target, prompt: "#{player} has assassinated you, #{target}. You must flip a card by calling `flip <card>`.")
				]
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

			def self.desc
				"Costs 3 coins. Target a player to lose a card. "
			end
		end
	end
end