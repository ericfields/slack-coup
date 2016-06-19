module CoupBot
	module Channels
		def self.included(base)
			base.extend(ClassMethods)
		end

		class << self
			attr_reader :channels
			@channels = {}
		end

		module ClassMethods
			@@channels = {}
	
			def channels
				@@channels
			end
			def channel(id)
				@@channels[id]
			end
			def add_channel(id)
				@@channels[id] = Channel.new(id)
			end
			def remove_channel(id)
				@@channels.delete id
			end
		end

		class Channel
			attr_reader :id
			attr_reader :users

			@@client = Slack::Web::Client.new(token: ENV['SLACK_API_TOKEN'])

			def initialize(channel_id)
				@id = channel_id
				@members = {}
				channel_members = @@client.channels_info(channel: @id)['channel']['members']
				channel_members.each do |member|
					@members[member['id']] = member
				end
			end

			def join(user_id, user_profile)
				@members[user_id] = user_profile
			end

			def leave(user_id)
				@members.delete user_id
			end
		end
	
	end
end