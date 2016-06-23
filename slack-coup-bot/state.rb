module SlackCoupBot
	module State
		cattr_accessor :game
		cattr_accessor :channel
		cattr_accessor :client

		cattr_accessor :reaction_time
		cattr_accessor :message_delay
		cattr_accessor :logger

		cattr_accessor :debug_options
	end
end