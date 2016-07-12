require 'actions/play_actions/play_action'

module SlackCoupBot
	module Actions
		class Tax < PlayAction
			def subactions
				[GainCoins.new(player, 3)]
			end

			def self.desc
				"Take three coins from the treasury."
			end
		end
	end
end