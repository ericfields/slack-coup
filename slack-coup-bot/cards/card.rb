require 'actions/play_actions'

module SlackCoupBot
	module Cards
		class Card
			include SlackCoupBot::Actions

			@@card_classes = nil

			class << self
				attr_accessor :action_classes
				attr_accessor :block_classes

				def actions(*actions)
					@action_classes = actions
				end

				def blocks(*actions)
					@block_classes = actions
				end

			  def actors(action)
			  	action = action.class unless action.is_a? Class
			    @@card_classes ||= ObjectSpace.each_object(singleton_class).select { |klass| klass < self }
			    @@card_classes.select do |klass|
			    	klass.load_actions
			    	klass.action_classes.include? action
			    end
			  end

			  def blockers(action)
			  	action = action.class unless action.is_a? Class
			    @@card_classes ||= ObjectSpace.each_object(singleton_class).select { |klass| klass < self }
			    @@card_classes.select do |klass|
			    	klass.load_actions
			    	klass.block_classes.include? action
			    end
			  end

				def acts?(action)
					self.actors(action).include? self
				end

				def blocks?(action)
					self.blockers(action).include? self
				end

			  def load_actions
			  	@action_classes ||= []
			  	@action_classes.append Actions::Block
			  	@block_classes ||= []
			  end

				def to_s
					"`#{self.name.split('::').last}`"
				end

				def info
					detail_strs = []
					if self.action_classes
						detail_strs << "Can #{self.action_classes}."
					end
					if self.block_classes
						detail_strs << "Blocks #{self.block_classes}."
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

			delegate :acts?, :blocks?, :to_s, :info, to: "self.class"
		end
	end
end