require 'actions/play_actions/play_action'

module SlackCoupBot
	module Actions
		class Income < PlayAction
			def subactions
				[GainCoins.new(player, 1)]
			end

			def verb
				"take #{to_s}"
			end

			def info
				"Take 1 coin from the treasury. " + super
			end
		end
	end
end