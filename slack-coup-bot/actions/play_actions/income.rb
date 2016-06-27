require 'actions/play_actions/play_action'

module SlackCoupBot
	module Actions
		class Income < PlayAction
			def subactions
				[GainCoins.new(player, 1)]
			end

			def desc
				"take #{to_s}"
			end
		end
	end
end