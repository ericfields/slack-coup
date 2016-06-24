require 'cards/card'

module SlackCoupBot
	module Cards
		class Captain < Card
			actions Steal
			blocks Steal
		end
	end
end