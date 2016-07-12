require 'cards/card'

module SlackCoupBot
	module Cards
		class Duke < Card
			performs Tax
			blocks ForeignAid
		end
	end
end