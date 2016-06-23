module SlackCoupBot
	module State
		cattr_accessor :game
		cattr_accessor :channel
		cattr_accessor :client

		cattr_accessor :wait_time
		cattr_accessor :logger
	end
end