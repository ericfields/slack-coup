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

		self.time_to_react = 20
		self.message_delay = 0.8

		self.debug_options = {
			min_players: 2,
			max_players: 6,
			coins_per_player: 2,
			cards_per_player: 2,
			shuffle_deck: true, 
			shuffle_players: true
		}

		self.debug_options.each do |k, v|
			new_val = ENV[k.to_s.upcase]
			if new_val
				if new_val == 'true'
					new_val = true
				elsif new_val == 'false'
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