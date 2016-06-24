require 'actions/play_actions/play_action'

module SlackCoupBot
	module Actions
		class ForeignAid < PlayAction
			def subactions
				[GainCoins.new(player, 2)]
			end

			def to_s
				"take `foreign aid`"
			end
		end
	end
end