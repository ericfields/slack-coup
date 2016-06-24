require 'actions/sub_actions/sub_action'

module SlackCoupBot
	module Actions
		class GainCoins < SubAction
			def initialize(player, count = nil)
				super(player)
				@count = count
			end

			def public_message(coins)
				"#{player} has received #{coins} coin(s)"
			end

			def evaluate(count = nil)
				@count ||= count
				@player.gain_coins @count
			end
		end
	end
end