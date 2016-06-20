class CoupError < StandardError

end

class CommandError < CoupError

end

class PlayerError < CoupError
	attr_accessor :player

	def initialize(player, msg)
		@player = player
		@msg = msg
	end
end

class ValidationError < CoupError

end

class SetupError < StandardError

end

class CallError < SetupError

end

class ConfigError < SetupError

end