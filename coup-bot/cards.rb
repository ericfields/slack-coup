require 'actions'

class Card
	@@card_classes = []

	class << self
		attr_reader :actions
		attr_reader :blocks

		@actions = [Block]
		@blocks = []

		def actions(*actions)
			@actions = actions
		end

		def blocks(*actions)
			@blocks = actions
		end

	  def actors(action)
	  	action = action.class unless action.is_a? Class
	    @@card_classes ||= ObjectSpace.each_object(singleton_class).select { |klass| klass < self }
	    @@card_classes.select do |klass|
	    	klass.actions.include? action
	    end
	  end

	  def blockers(action)
	  	action = action.class unless action.is_a? Class
	    @@card_classes ||= ObjectSpace.each_object(singleton_class).select { |klass| klass < self }
	    @@card_classes.select do |klass|
	    	klass.blocks.include? action
	    end
	  end
	end

	attr_reader :flipped

	def flip
		@flipped = true
	end

	def hide
		@flipped = false
	end

	def to_s
		self.class.name
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
