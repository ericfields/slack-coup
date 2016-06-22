require 'state'

module SlackCoupBot
	module Commands
		class Base < SlackRubyBot::Commands::Base
			extend State

			class << self
				@logger = nil
				def invoke(client, data)
					@logger ||= SlackRubyBot::Client.logger 
					begin
						super(client, data)
					rescue CoupError => e
						client.say text: e.message, channel: data.channel
					rescue => e
						client.say text: "Internal error", channel: data.channel
						@logger.error "#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
					end
				end
			end

		end
	end
end