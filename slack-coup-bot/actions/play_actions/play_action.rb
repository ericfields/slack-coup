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

			def public_message(result)
				"#{player}'s #{self} action has completed."
			end

			class << self
				def actors
					Cards::Card.actors(self)
				end

				def blockers
					Cards::Card.blockers(self)
				end

				def blockable?
					! blockers.empty?
				end

				def challengable?
					! actors.empty?
				end

				def info
					info_strs = []
					if actors.any?
						info_strs << "Can be performed by #{actors}."
					end
					if blockers.any?
						info_strs << "Blocked by #{blockers}."
					end
					if info_strs.empty?
						info_strs << "Cannot be blocked or challenged."
					end
					info_strs.join(' ')
				end
			end

			delegate :actors, :blockers, :blockable?, :challengable?, :info, to: "self.class"
		end
	end
end