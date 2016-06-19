class PlayerError < StandardError
	attr_accessor :player

	def initialize(player, msg)
		@player = player
		@msg = msg
	end
end