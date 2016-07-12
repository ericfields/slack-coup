require 'cards/card'

module SlackCoupBot
	module Cards
		class Captain < Card
			performs Steal
			blocks Steal
		end
	end
end