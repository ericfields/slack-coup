require 'actions'
require 'errors/validation_error'

class Reaction < Action
	attr_reader :action
	
	def initialize(player, action)
		super(player)
		@action = action
	end

	def validate(*args)
		super(*args)
		if @action.is_a? TargetedAction && @player != @action.target
			raise ValidationError, "Only #{@action.target} can #{self} this action"
		end
		true
	end
end

class Block < Reaction
	on_validate do |player, action|
		unless action.class.blockable?
			raise ValidationError, "#{action} cannot be blocked"
		end
	end
end

class Challenge < Reaction
	on_validate do |player, action|
		unless action.class.challengable?
			raise ValidationError, "#{action} cannot be challenged"
		end
	end

	on_begin do |player, action|
		respond "#{player} has challenged #{action.player}'s #{action}! #{action.player}, please reveal a card with 'flip <card>'",
		callbacks: [Flip.new(@player, 1)]
	end

	on_perform do |player, action, card|
		if @action.class.actors.include? card.class
			respond "#{@player}'s challenge has succeeded! #{@action.player} must flip a card",
				callbacks: [Flip.new(@action.player, 1)]
		else
			respond "#{@player}'s challenge has failed! #{player} must flip a card",
				callbacks: [Flip.new(@player, 1), Return.new(@target, 1)]	end
		end
	end
end