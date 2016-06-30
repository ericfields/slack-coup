require 'actions/play_actions/play_action'

module SlackCoupBot
	module Actions
		class Tax < PlayAction
			def subactions
				[GainCoins.new(player, 3)]
			end

			def info
				"Tale three coins from the treasury. " + super
			end
		end
	end
end