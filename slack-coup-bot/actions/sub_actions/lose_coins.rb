require 'actions/sub_actions/sub_action'

module SlackCoupBot
	module Actions
		class LoseCoins < SubAction
			def initialize(player, count = nil)
				super(player)
				@count = count
			end

			def evaluate(count = nil)
				@count ||= count
				@player.lose_coins @count
			end

			def public_message(coins)
				"#{player} has lost #{coins} coins"
			end
		end
	end
end