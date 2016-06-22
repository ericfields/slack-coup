$LOAD_PATH.unshift(File.dirname(__FILE__))

#Slack.config.token = ENV['SLACK_API_TOKEN']

SlackRubyBot.configure do |c|
	c.token = ENV['SLACK_API_TOKEN']
end

require 'slack-ruby-bot'

require 'game'
require 'player'
require 'user'
require 'actions'
require 'cards'
require 'errors'
require 'patches'

SlackRubyBot::Client.logger.level = Logger::INFO

class CoupBot < SlackRubyBot::Bot
	@game = nil
	@channel = nil

	@wait_time = 5

	@logger = SlackRubyBot::Client.logger

	match /(?<action>income|tax|foreign aid)/ do |client, data, match|
		if data.channel[0] == 'D'
			client.say text: "Please perform this action in a regular channel, not as a direct message", channel: data.channel
			next
		end

		begin
			if @game.nil?
				next
			elsif ! @game.started?
				raise CommandError, "The game has not yet started"
			end

			player = get_player(data.user)

			# Check turn
			if player != @game.current_player
				raise CommandError, "It is not your turn, #{player}!"
			end

			action = class_for_action(match[:action]).new(player)

			action.validate

			# Push action along with subactions onto stack
			@game.stack.push action
			action.subactions.reverse.each do |subaction|
				@game.stack.push subaction
			end

			@logger.info "Current game stack: #{@game.stack.show}"

			client.say text: "#{player} will take #{action}!", channel: data.channel

			should_do = true

			if action.blockable? || action.challengable?
				client.say text: "Waiting for reactions...", channel: data.channel
				wait_start = Time.now

				loop do
					if @game.stack.last.is_a? Reaction
						should_do = false
						break
					end
					sleep 0.1
				end while Time.now - wait_start < @wait_time
				if should_do
					client.say text: "#{player}'s #{action} will proceed!", channel: data.channel
				end
			end

			if should_do
				last_result = nil
				while ! @game.stack.empty?
					action = @game.stack.pop

					response = action.do *last_result
					last_result = response.result

					print_response response
				end

				evaluate_game
			end
		rescue CoupError => e
			client.say text: e.message, channel: data.channel
		rescue => e
			@logger.error "#{e.class}: #{e.message}. Backtrace:\n\t#{e.backtrace.join("\n\t")}"
			client.say text: "Internal error, see log", channel: data.channel
		end
	end

	match 'debug' do |client, data, match|
		if data.channel[0] == 'D'
			client.say text: "Can't debug - you're in a direct message channel", channel: data.channel
			next
		end
		
		open_lobby(client, data.channel, debug: true)

		User.all_users.sort_by{|u| u.name}.each do |user|
			next if user.name == 'coup-bot'
			@game.add_player user
		end

		start_game

		client.say text: "A game of Coup has been started!\n\nPlayers:\n\n#{@game.player_list}", channel: data.channel
	end

	match 'lobby' do |client, data, match|
		if data.channel[0] == 'D'
			client.say text: "You can't start a lobby in a direct message channel. Run this command in a general Slack channel.", channel: data.channel
			next
		end

		if @game
			if @game.started?
				client.say text: "There is already a game under way, you loser.\n\nPlayers:\n\n#{@game.player_list}", channel: data.channel
			else
				client.say text: "A lobby for Coup is already open, so shut up.\n\nPlayers:\n\n#{@game.player_list}", channel: data.channel
			end
			next
		end

		client.say text: "Starting up a Coup lobby...", channel: data.channel

		open_lobby(client, data.channel)

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
			start_game
			
			client.say text: "A game of Coup has started!", channel: data.channel
			client.say text: "Play order:\n#{@game.player_list}", channel: data.channel
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

	match /invite (?<players>(\w+(\s+)?)+)/ do |client, data, match|
		player_names = match[:players].split ' '
		begin
			users = player_names.collect do |player_name|
				user = User.with_name(player_name)
				if user.nil?
					raise CommandError, "#{user_name} is not a member of the channel for the current game"
				end
				user
			end

			users.each do |user|
				@game.add_player user.id
			end

			client.say text: "Added #{player_names} to the game", channel: data.channel
		rescue CoupError => e
			client.say text: e.message, channel: data.channel
		end
	end

	match 'status' do |client, data, match|
		if @game.nil?
			client.say text: "No lobby is currently open for Coup.", channel: data.channel
		elsif ! @game.started?
			client.say text: "A lobby for Coup is currently open.\n\nPlayers:\n\n#{@game.player_list}", channel: data.channel
		else
			client.say text: "A game of Coup is under way.\n\nPlayers:\n\n#{@game.player_list}", channel: data.channel
		end
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

	class << self
		def print_response(response)
			@client.say text: response.public_message, channel: @channel

			if response.private_message
				whisper response.user.id, response.private_message
			end
		end

		def whisper(user, message)
			user = user.id if user.is_a? User

			web_client = @client.web_client
			im_open_response = web_client.im_open(user: user)
			if im_open_response.nil? || im_open_response['ok'] != true
				raise InternalError, "Could not send direct message to user #{user} (#{User.find(user).name})"
			end

			im_channel = im_open_response['channel']['id']

			@logger.info "Direct message channel: #{im_channel}"
			@client.say text: message, channel: im_channel
		end

		def open_lobby(client, channel, debug: false)
			@client = client
			@channel = channel
			@game = Game.new(channel, debug)
			User.load_members(channel)
		end

		def start_game
			@game.start

			@game.players.values.each do |player|
				whisper player.user.id, "You have the #{player.cards} cards"
			end
		end

		def evaluate_game
			return if @game.nil? || ! @game.started?

			@game.players.values.select{|p| ! p.eliminated? }.each do |player|
				if player.remaining_cards == 0
					@logger.info "#{player} has cards #{player.cards} - #{player.remaining_cards} are flipped and #{player} is out of the game"
					player.eliminate
					@client.say text: "#{player} is out of the game!", channel: @channel
				end
			end

			if @game.remaining_players == 1
				winner = @game.players.values.find{|p| ! p.eliminated? }
				@client.say text: "#{winner} has won the game!"
				end_game
			else
				@game.advance
				@client.say text: "It is now #{@game.current_player}'s turn to act", channel: @channel
			end
		end

		def get_player(user)
			player = @game.players[user]
			if player.nil?
				raise CommandError, "You are not in the game!"
			elsif player.eliminated?
				raise CommandError, "You have already been eliminated from the game, #{player}."
			end
			player
		end

		def class_for_action(action_name)
			begin
				Object.const_get(action_name.to_s.capitalize)
			rescue NameError
				raise InternalError, "#{action_name} does not map to a recognized class"
			end
		end

		def class_for_card(card_name)
			begin
				Object.const_get(action_name.to_s.capitalize)
			rescue NameError
				raise CommandError, "#{card_name} is not a card!"
			end
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
end

class CoupBotServer < SlackRubyBot::Server
	on 'message' do |client, data|
		if data.subtype == 'channel_join'
			User.cache_user data.user
		elsif data.subtype == 'channel_leave'
			User.uncache_user data.user
		end
	end
end

CoupBot.run