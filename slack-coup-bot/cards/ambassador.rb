require 'cards/card'

module SlackCoupBot
	module Cards
		class Ambassador < Card
			performs Exchange
			blocks Steal
		end
	end
end