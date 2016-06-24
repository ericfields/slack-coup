module SlackCoupBot
	module Actions
		class Cancel
			attr_reader :action
			def initialize(action)
				@action = action
			end

			def to_s
				"cancellation"
			end
		end
	end
end