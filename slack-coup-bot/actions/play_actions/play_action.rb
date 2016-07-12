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
				def performers
					Cards::Card.performers(self)
				end

				def blockers
					Cards::Card.blockers(self)
				end

				def blockable?
					! blockers.empty?
				end

				def challengable?
					! performers.empty?
				end

				def desc
					""
				end

				def long_desc
					desc_strs = [desc]
					desc_strs << "Can be performed by #{performers.any? ? performers : 'anyone'}."
					if blockers.any?
						desc_strs << "Blocked by #{blockers}."
					end
					if performers.empty? && blockers.empty?
						desc_strs << "Cannot be blocked or challenged."
					end
					desc_strs.join(' ')
				end
			end

			delegate :performers, :blockers, :blockable?, :challengable?, :desc, to: "self.class"
		end
	end
end