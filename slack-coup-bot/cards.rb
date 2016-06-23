require 'actions/play_actions'
require 'actions/targeted_actions'
require 'actions/reactions'

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

			  def load_actions
			  	@action_classes ||= []
			  	@action_classes.append Actions::Block
			  	@block_classes ||= []
			  end
			end

			def acts?(action)
				self.class.actors(action).include? self.class
			end

			def blocks?(action)
				self.class.blockers(action).include? self.class
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

			def to_s
				self.class.name.split('::').last
			end
		end

		class Ambassador < Card
			actions Exchange
			blocks Steal
		end

		class Assassin < Card
			actions Assassinate
		end

		class Captain < Card
			actions Steal
			blocks Steal
		end

		class Contessa < Card
			blocks Assassinate
		end

		class Duke < Card
			actions Tax
			blocks ForeignAid
		end
	end
end