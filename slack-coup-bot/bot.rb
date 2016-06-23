$LOAD_PATH.unshift(File.dirname(__FILE__))

SlackRubyBot.configure do |c|
	c.token = ENV['SLACK_API_TOKEN']
end

require 'slack-ruby-bot'

require 'game'
require 'player'
require 'user'

require 'actions'
require 'commands'
require 'cards'

require 'errors'
require 'patches'


SlackRubyBot::Client.logger.level = Logger::INFO

module SlackCoupBot
	class Bot < SlackRubyBot::Bot
		extend State

		self.reaction_time = 8
		self.message_delay = 1
		self.logger = SlackRubyBot::Client.logger

		self.debug_options = {
			coins_per_player: 7, 
			shuffle_deck: false, 
			shuffle_players: false
		}
	end

	class Server < SlackRubyBot::Server
		on 'message' do |client, data|
			if data.subtype == 'channel_join'
				User.cache_user data.user
			elsif data.subtype == 'channel_leave'
				User.uncache_user data.user
			end
		end
	end
end

SlackCoupBot::Bot.run