module SlackCoupBot
	module State
		cattr_accessor :game
		cattr_accessor :channel
		cattr_accessor :client

		cattr_accessor :wait_time
		cattr_accessor :logger

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
				whisper player.user.id, "You have the #{player.cards} cards"
			end
		end

		def end_game
			@game = nil
		end
	end
end