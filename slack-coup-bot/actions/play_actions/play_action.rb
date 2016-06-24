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

			def actors
				Cards::Card.actors(self.class)
			end

			def blockers
				Cards::Card.blockers(self.class)
			end

			def blockable?
				! blockers.empty?
			end

			def challengable?
				! actors.empty?
			end

			def public_message(result)
				"#{player}'s #{self} action has completed."
			end
		end
	end
end