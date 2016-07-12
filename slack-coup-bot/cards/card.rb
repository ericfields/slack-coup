require 'actions/play_actions'

module SlackCoupBot
	module Cards
		class Card
			include SlackCoupBot::Actions

			@@members = nil

			class << self
				def performs(*actions)
					@action_classes = actions
				end

				def blocks(*actions)
					@block_classes = actions
				end

				def members
			    @members ||= ObjectSpace.each_object(singleton_class).select { |klass| klass < self }
				end

			  def performers(action)
			  	action = action.class unless action.is_a? Class
			    members.select do |card|
			    	card.performs? action
			    end
			  end

			  def blockers(action)
			  	action = action.class unless action.is_a? Class
			    members.select do |card|
			    	card.blocks? action
			    end
			  end

				def performs?(action)
					action = action.class unless action.is_a? Class
					@action_classes ||= []
					@action_classes.include? action
				end

				def blocks?(action)
					action = action.class unless action.is_a? Class
					@block_classes ||= []
					@block_classes.include? action
				end

				def to_s
					"`#{self.name.split('::').last}`"
				end

				def desc
					detail_strs = []
					if !@action_classes.blank?
						detail_strs << "Can #{@action_classes}."
					end
					if !@block_classes.blank?
						detail_strs << "Blocks #{@block_classes}."
					end
					detail_strs.join(' ')
				end
			end

			def initialize
				@flipped = false
			end

			def flip
				@flipped = true
				self
			end

			def flipped?
				@flipped
			end

			def hide
				@flipped = false
				self
			end

			def ==(other)
				other.class == self.class
			end

			delegate :performs?, :blocks?, :to_s, :info, to: "self.class"
		end
	end
end