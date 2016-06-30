require 'actions/play_actions/play_action'

module SlackCoupBot
	module Actions
		class ForeignAid < PlayAction
			def subactions
				[GainCoins.new(player, 2)]
			end

			def to_s
				"`foreign aid`"
			end

			def verb
				"take #{to_s}"
			end

			def info
				"Take two coins from the treasury. " + super
			end
		end
	end
end