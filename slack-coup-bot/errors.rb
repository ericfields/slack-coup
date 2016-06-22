class CoupError < StandardError

end

class CommandError < CoupError

end

class ValidationError < CoupError

end

class InternalError < StandardError

end

class CallError < InternalError

end

class ConfigError < InternalError

end