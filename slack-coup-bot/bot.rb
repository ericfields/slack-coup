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


SlackRubyBot::Client.logger.level = Logger::INFO

module SlackCoupBot
	class Bot < SlackRubyBot::Bot
		extend State

		self.logger = SlackRubyBot::Client.logger

		self.time_to_react = 10
		self.message_delay = 0.8

		self.debug_options = {
			min_players: 2,
			max_players: 2,
			coins_per_player: 7,
			cards_per_player: 1,
			shuffle_deck: false, 
			shuffle_players: false
		}
	end
end

SlackCoupBot::Bot.run