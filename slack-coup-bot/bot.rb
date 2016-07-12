$LOAD_PATH.unshift(File.dirname(__FILE__))

SlackRubyBot.configure do |c|
	c.token = ENV['SLACK_API_TOKEN']
end

require 'slack-ruby-bot'
require 'server'
require 'patches'
require 'errors'

require 'game'
require 'player'
require 'user'

require 'actions'
require 'commands'
require 'cards'

if ENV['DEBUG_LOG'] && ENV['DEBUG_LOG'].downcase == 'true'
	SlackRubyBot::Client.logger.level = Logger::DEBUG
else
	SlackRubyBot::Client.logger.level = Logger::INFO
end

module SlackCoupBot
	class Bot < SlackRubyBot::Bot
		extend State

      help do
        title 'Slack Coup Bot'
        desc 'Plays a game of Coup'

        command 'game lobby' do
          desc "Open a lobby for a game of Coup"
          long_desc "Players can join an open Coup lobby with *game join*.\n" +
          "4-6 players are required for Coup.\n"
          + "Any player can start the game with *game start*"
        end

        command 'game start' do
          desc "Start the game"
          long_desc "Start a game of Coup. A lobby must be open with at least four players to start the game"
        end

        command 'game join' do
          desc "Join a lobby"
          long_desc "Join an open Coup lobby. No more than six players can be present in a game"
        end

        command 'game leave' do
          desc "Leave a game/lobby"
          long_desc "Leave a Coup game or lobby"
        end

        command 'game invite' do
          desc "Invite players to a lobby"
          long_desc "Invite one or more players to an open lobby. Example: `game invite <player1> <player2>...`"
        end

        command 'game kick' do
          desc "Remove players from a lobby/game"
          long_desc "Remove one or more players from a lobby or game. Example: `game kick <player1> <player2>...`"
        end

        command 'game end' do
          desc "End the game"
          long_desc "End an active game of Coup, or close a lobby"
        end

        command 'cards' do
          desc "View your cards"
          long_desc "View the cards in your hand. Sent as a private message."
        end

        command 'status' do
          desc "Show the game status"
          long_desc "Display the current status of all players, with their current coins and revealed cards"
        end

        SlackCoupBot::Actions::PlayAction.members.reverse.collect do |klass|
          command_name = klass.name.to_s.split('::').last.split(/(?=[A-Z])/).join(' ').downcase
          command command_name, :actions do
            desc klass.desc
          	long_desc klass.long_desc
          end
        end

        SlackCoupBot::Cards::Card.members.reverse.collect do |klass|
          command_name = klass.name.to_s.split('::').last.split(/(?=[A-Z])/).join(' ')
          command command_name, :cards do
            desc klass.desc
          end
        end
      end

		self.logger = SlackRubyBot::Client.logger

		self.message_delay = 0.8

		self.debug_options = {
			min_players: 4,
			max_players: 6,
			coins_per_player: 2,
			cards_per_player: 2,
			shuffle_deck: true, 
			shuffle_players: true
		}

		self.debug_options.each do |k, v|
			new_val = ENV[k.to_s.upcase]
			if new_val
				if new_val.downcase == 'true'
					new_val = true
				elsif new_val.downcase == 'false'
					new_val = false
				elsif new_val.to_i.to_s == new_val
					new_val = Integer(new_val)
				end
				self.debug_options[k] = new_val
			end
		end
	end
end

SlackCoupBot::Bot.run