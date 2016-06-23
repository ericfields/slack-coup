module SlackCoupBot
	module State
		cattr_accessor :game
		cattr_accessor :channel
		cattr_accessor :client

		cattr_accessor :reaction_time
		cattr_accessor :action_pause
		cattr_accessor :logger

		cattr_accessor :debug_options
	end
end