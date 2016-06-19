$LOAD_PATH.unshift(File.dirname(__FILE__))

ENV['SLACK_API_TOKEN'] = 'xoxb-51786285617-etePfzwRhqwJR6WfIx1Y9ix0'
Slack.config.token = ENV['SLACK_API_TOKEN']

require 'slack-ruby-bot'
require 'game'
require 'player'
require 'channels'
require 'errors'

module CoupBot
	class Server < SlackRubyBot::Server
		include Channels

		on 'channel_joined' do |client, data|
			add_channel data.channel.id
		end
		on 'channel_left' do |client, data|
			remove_channel data.channel
		end

		on 'message' do |client, data|
			# Do not on_perform channel operations for direct messages
		 	unless data.channel[0] == 'D'
				if channel(data.channel).nil? && data.channel[0]
					add_channel data.channel
				end

				case data.subtype
				when 'channel_join'
					channel(data.channel).join(data.user, data.user_profile)
				when 'channel_leave'
					channel(data.channel).leave(data.user)
				end

			end
		end
	end

	class Bot < SlackRubyBot::Bot
		include Channels

		@games = {}

		match 'lobby' do |client, data, match|
			game = @games[data.channel]
			if game
				if game.started?
					client.say text: "There is already a under way.", channel: data.channel
				else
					client.say text: "A game lobby for Coup is currently open", channel: data.channel
				end
				return
			end

			game = Game.new
			game.add_player User.find(data['user'])
			client.say text: "A new lobby for a game of Coup has been opened.\n\nPlayers:\n\n#{game.player_list}", channel: data.channel
		end

		match 'start' do |client, data|
			game = @games[data.channel]
			if game.nil?
				client.say text: "No Coup lobby has been opened", channel: data.channel
			elsif game.started?
				client.say text: "A game of Coup is already under way."
			elsif game.players.count < 4
				client.say text: "Not enough players for a game of Coup. A minimum of 4 players is required."
			
			else
				game.start
				
				client.say text: "A game of Coup has started!", channel: data.channel
				client.say text: "Play order:\n#{game.player_list}", channe: data.channel

				game.players.keys.each do |user|
					peek_cards client, user
				end
			end
		end

		match 'join' do |client, data|
			game = @games[data.channel]

			user = User.data['user']

			if game.nil?
				client.say text: "No game has been started. Start a new game of Coup by typing 'lobby'.", channel: data.channel
				return
			end

			if game.players == 6
				client.say text: "You cannot join - there is already a maximum of 6 players in this game.", channel: data.channel
				return
			end

			if game.players[user]
				client.say text: "You are already in the game.", channel: data.channel
				return
			end

			player = game.add_player user

			client.say text: "#{player} has joined the game", channel: data.channel
		end

		match 'leave' do |client, data|
			@game = games[data.channel]
			if game.nil?
				client.say text: "No lobby has been opened.", channel: data.channel
				return
			end

			user = data['user']

			removed_player = game.remove_player user
			if removed_player.nil?
				client.say text: "You are not in the game.", channel: data.channel
			else
				client.say text: "#{User.name_for(removed_player)} has left the game", channel: data.channel
				if game.players.count == 0
					abort_game(client, data)
				end
			end
		end

		match /^kick (?<user>\w+)/ do |client, data, match|
			game = @games[data.channel]
			return if game.nil?

			user_name = match[:user]
			user = User.by_name(user_name)
			if user.nil?
				client.say text: "User #{user_name} does not exist", channel: data.channel
			else
				remove_player(client, data, user)
			end
		end

		match 'end' do |client, data|
			game = @games[data.channel]

			return if game.nil?

			abort_game(client, data)
		end

		match /check|peek/ do |client, data, match|
			user = data['user']

			return if game.players[user].nil?

			peek_cards client, user
		end

		def remove_player(client, data, user)
			player_name = User.name_for(removed_player)

			# Check if the player doing the removing is the same as the player being removed
			if data['user'] == user
				subject = "You are"
				verb = "left"
			else
				subject = "#{player_name} is"
				verb = "been kicked from"
			end

			removed_player = game.remove_player user
			if removed_player.nil?
				client.say text: "#{subject} not in the game.", channel: data.channel
			else
				client.say text: "#{player_name} has #{verb} the game", channel: data.channel
				if game.players.count == 0
					abort_game(client, data)
				end
			end
		end

		def peek_cards(client, user)
			cards = game.players[user].cards

			# Only show cards directly to user
			user_direct_message_channel = user.sub 'U', 'D'

			if cards.empty?
				client.say text: "You have no more cards. You're out of the game!", channe: user_direct_message_channel
			else
				client.say text: "Your cards:\n#{cards.join("\n")}", channel: user_direct_message_channel
			end
		end

		def show_players(client, data)
			return if game.nil?

			client.say text: "Players:\n\n#{game.player_list}", channel: data.channel
		end

		def abort_game(client, data)
			game = nil
			client.say text: "This game of Coup has ended.", channel: data.channel
		end
	end
=end
end

server = CoupBot::Server.new
server.run