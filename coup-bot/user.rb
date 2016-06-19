class User
	attr_reader :id
	attr_reader :name

	def initialize(id, name)
		@id = id
		@name = name
	end

	class << self
		@client = Slack::Web::Client.new(token: ENV['SLACK_API_TOKEN'])
		@user_cache = {}

		def in_channel(channel)
			channel_users = @client.channels_info(channel: channel)['members']

		end

		def find(user_id)
			@user_cache[user_id]
		end

		# Find a user by name
		def find_by_name(user_name)
			load_users
			@user_cache.find{|user| user.name == user_name}
		end

		def load_users(channel)
			if @user_info.nil? || force
				user_info = @client.users_list['users']
				@user_cache = {}
				user_info.each do |user|
					@user_cache[user['id']] = User.new(user['id'], user['name'])
				end
			end
		end
	end
end