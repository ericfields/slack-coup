require 'actions/sub_actions'
require 'cards'

module SlackCoupBot
	module Actions
		class PlayAction < Action
			def initialize(player)
				super(player)
				@subactions = []
			end

			def subactions
				[]
			end

			def blockable?
				! Cards::Card.blockers(self.class).empty?
			end

			def challengable?
				! Cards::Card.actors(self.class).empty?
			end

			def public_message(result)
				"#{player}'s #{self} action has completed."
			end
		end
	end
end