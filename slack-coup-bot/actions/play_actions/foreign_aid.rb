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

			def self.desc
				"Take two coins from the treasury."
			end
		end
	end
end