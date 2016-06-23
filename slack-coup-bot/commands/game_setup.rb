require 'commands/base'

module SlackCoupBot
	module Commands
		class GameSetup < Base
			class << self
				def open_lobby(client, channel, **game_options)
					client.say text: "Starting up a Coup lobby...", channel: channel

					self.client = client
					self.channel = channel
					self.game = Game.new(channel, game_options)
					User.load_members(channel)
				end
			end

			match 'debug' do |client, data, match|
				if data.channel[0] == 'D'
					raise CommandError, "Can't debug - you're in a direct message channel"
					next
				end

				open_lobby(client, data.channel, self.debug_options)

				User.all_users.sort_by{|u| u.name}.each do |user|
					next if user.name == 'coup-bot'
					game.add_player user
				end

				start_game

				client.say text: "A game of Coup has been started!\n\nPlayers:\n\n#{game.player_list}\n\nIt is #{game.current_player}'s turn.", channel: data.channel
			end

			match 'coup lobby' do |client, data, match|
				if data.channel[0] == 'D'
					client.say text: "You can't start a lobby in a direct message channel. Run this command in a general Slack channel.", channel: data.channel
					next
				end

				if game
					if game.started?
						client.say text: "There is already a game under way.\n\nPlayers:\n\n#{game.player_list}", channel: data.channel
					else
						client.say text: "A lobby for Coup is already open, so shut up.\n\nPlayers:\n\n#{game.player_list}", channel: data.channel
					end
					next
				end

				open_lobby(client, data.channel)

				game.add_player data.user

				client.say text: "A new lobby for a game of Coup has been opened.\n\nPlayers:\n\n#{game.player_list}", channel: data.channel
			end

			match 'start' do |client, data|
				if game.nil?
					client.say text: "No Coup lobby has been opened", channel: data.channel
				elsif game.started?
					client.say text: "A game of Coup is already under way.", channel: data.channel
				elsif game.players.count < 4
					client.say text: "Not enough players for a game of Coup. A minimum of 4 players is required.", channel: data.channel
				
				else
					start_game
					
					client.say text: "A game of Coup has started!", channel: data.channel
					client.say text: "Play order:\n#{game.player_list}", channel: data.channel
				end
			end

			match 'join' do |client, data|
				if game.nil?
					client.say text: "No game has been started. Start a new game of Coup by typing 'lobby'.", channel: data.channel
					next
				end

				if game.players == 6
					client.say text: "You cannot join - there is already a maximum of 6 players in this game.", channel: data.channel
					next
				end

				if game.players[data.user]
					client.say text: "You are already in the game.", channel: data.channel
					next
				end

				player = game.add_player data.user

				client.say text: "#{player} has joined the game.\n\nPlayers:\n\n#{game.player_list}", channel: data.channel
			end

			match 'leave' do |client, data|
				next if game.nil?

				removed_player = game.remove_player data.user

				next if removed_player.nil?

				client.say text: "#{removed_player} has left the game.\n\nPlayers:\n\n#{game.player_list}", channel: data.channel
				
				if game.players.count == 0
					end_game

					client.say text: "No players are in the Coup lobby. The lobby is now closed.", channel: data.channel
				end
			end

			match /invite (?<players>(\w+(\s+)?)+)/ do |client, data, match|
				player_names = match[:players].split ' '

				users = player_names.collect do |player_name|
					user = User.with_name(player_name)
					if user.nil?
						raise CommandError, "#{user_name} is not a member of the channel for the current game"
					end
					user
				end

				users.each do |user|
					game.add_player user.id
				end

				client.say text: "Added #{player_names} to the game", channel: data.channel
			end

			match /kick (?<players>(\w+(\s+)?)+)/ do |client, data, match|
				player_names = match[:players].split ' '

				users = player_names.collect do |player_name|
					user = User.with_name(player_name)
					if user.nil?
						raise CommandError, "#{user_name} is not a member of the channel for the current game"
					end
					user
				end

				users.each do |user|
					removed_player = game.remove_player user.id
					if removed_player
						client.say text: "Removed #{player_names} from the game", channel: data.channel
					else
						client.say text: "Player #{user.name} is not in the game", channel: data.channel
					end
				end
			end

			match 'status' do |client, data, match|
				if game.nil?
					client.say text: "No lobby is currently open for Coup.", channel: data.channel
				elsif ! game.started?
					client.say text: "A lobby for Coup is currently open.\n\nPlayers:\n\n#{game.player_list}", channel: data.channel
				else
					client.say text: "A game of Coup is under way.\n\nStatus:\n\n#{game.status}", channel: data.channel
				end
			end

			match 'end' do |client, data|
				next if game.nil?

				end_game
				client.say text: "This game of Coup has ended.", channel: data.channel
			end
		end
	end
end