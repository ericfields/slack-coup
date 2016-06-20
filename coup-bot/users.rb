require 'pp'

module Users
	@@client ||= Slack::Web::Client.new(token: ENV['SLACK_API_TOKEN'])
	@@user_cache ||= {}

	# Find a user by name
	def id_for(user_name)
		user = @@user_cache[user_name]
		if user.nil?
			load_users
			user = @@user_cache[user_name]
		end
		user
	end

	def name_for(user_id)
		name = @@user_cache.key(user_id)
		if name.nil?
			load_users
			name = @@user_cache.key(user_id)
		end
		name
	end

	private

	def load_users
		members = @@client.channels_info(channel: @channel)['channel']['members']
		members.each do |user|
			user_info = @@client.users_info(user: user)['user']
			user_name = user_info['name']
			user_id = user_info['id']
			@@user_cache[user_name] = user_id
		end
	end
end