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

				def whisper(user, message)
					user = user.id if user.is_a? User

					web_client = self.client.web_client
					im_open_response = web_client.im_open(user: user)
					if im_open_response.nil? || im_open_response['ok'] != true
						raise InternalError, "Could not send direct message to user #{user} (#{User.find(user).name}). im.open response: #{im_open_response}"
					end

					im_channel = im_open_response['channel']['id']

					self.client.say text: message, channel: im_channel
				end

				def start_game
					game.start

					game.players.values.each do |player|
						remaining_cards = player.cards.select{|c| ! c.flipped? }
						whisper player.user.id, "You have the #{player.cards} cards"
					end
				end

				def end_game
					self.game = nil
				end
			end

		end
	end
end