require 'cards/card'

module SlackCoupBot
	module Cards
		class Ambassador < Card
			actions Exchange
			blocks Steal
		end
	end
end