$LOAD_PATH.unshift(File.dirname(__FILE__))

Slack.config.token = ENV['SLACK_API_TOKEN']

require 'slack-ruby-bot'

require 'game'
require 'player'
require 'errors'
require 'users'

#SlackRubyBot::Client.logger.level = Logger::WARN

class CoupBot < SlackRubyBot::Bot
	include Users

	@game = nil
	@channel = nil

	@actions = ['income', 'tax', 'foreign aid']

	match '(?<action>\w+)' do |client, data, match|
		player = get_player(data.user)

		action_class = Object.const_get(match[:action].capitalize)
		action = action_class.new(player)
		@game.current_action = action
	end

	match 'lobby' do |client, data, match|
		if data.channel[0] == 'D'
			client.say text: "Cannot start a lobby in a direct message channel. Run this command in a general Slack channel.", channel: data.channel
			next
		end

		if @game
			if @game.started?
				client.say text: "There is already a game under way.\n\nPlayers:\n\n#{@game.player_list}", channel: data.channel
			else
				client.say text: "A lobby for Coup is already open.\n\nPlayers:\n\n#{@game.player_list}", channel: data.channel
			end
			next
		end

		@channel = data.channel
		@game = Game.new(data.channel)
		@game.add_player data.user

		client.say text: "A new lobby for a game of Coup has been opened.\n\nPlayers:\n\n#{@game.player_list}", channel: data.channel
	end

	match 'start' do |client, data|
		if @game.nil?
			client.say text: "No Coup lobby has been opened", channel: data.channel
		elsif @game.started?
			client.say text: "A game of Coup is already under way.", channel: data.channel
		elsif @game.players.count < 4
			client.say text: "Not enough players for a game of Coup. A minimum of 4 players is required.", channel: data.channel
		
		else
			@game.start
			
			client.say text: "A game of Coup has started!", channel: data.channel
			client.say text: "Play order:\n#{@game.player_list}", channel: data.channel

			@game.players.each do |player|
				user = player.user
				dm_channel = user
				dm_channel[0] = 'D'

			end
		end
	end

	match 'join' do |client, data|
		if @game.nil?
			client.say text: "No game has been started. Start a new game of Coup by typing 'lobby'.", channel: data.channel
			next
		end

		if @game.players == 6
			client.say text: "You cannot join - there is already a maximum of 6 players in this game.", channel: data.channel
			next
		end

		if @game.players[data.user]
			client.say text: "You are already in the game.", channel: data.channel
			next
		end

		player = @game.add_player data.user

		client.say text: "#{player} has joined the game.\n\nPlayers:\n\n#{@game.player_list}", channel: data.channel
	end

	match 'leave' do |client, data|
		next if @game.nil?

		begin
			removed_player = @game.remove_player data.user
		rescue CoupError => e
			client.say text: e.message, channel: data.channel
		else
			client.say text: "#{removed_player} has left the game.\n\nPlayers:\n\n#{@game.player_list}", channel: data.channel
			
			if @game.players.count == 0
				end_game

				client.say text: "No players are in the Coup lobby. The lobby is now closed.", channel: data.channel
			end
		end
	end

	match 'end' do |client, data|
		next if @game.nil?

		end_game
		client.say text: "This game of Coup has ended.", channel: data.channel
	end

	def get_player(user)
		player = @game.players[user]
		if player.nil?
			raise CommandError, "Player is not in the game"
		end
		player
	end

	def add_player(user)
		@game.add_player user
	end

	def remove_player(user)
		removed_player = @game.remove_player user
		if removed_player.nil?
			raise CommandError, "#{subject} not in the game."
		end
	end

	def end_game
		@game = nil
	end
end

CoupBot.run