require 'state'

module SlackCoupBot
	class UserServer < SlackRubyBot::Server
		extend State
		on 'message' do |client, data|
			if data.subtype == 'channel_join'
				logger.info "User #{data.user_profile.name} has joined the channel, adding to user cache."
				User.cache_user data.user
			elsif data.subtype == 'channel_leave'
				logger.info "User #{data.user_profile.name} has left the channel, removing from user cache"
				User.uncache_user data.user
			end
		end
	end
end