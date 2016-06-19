require 'patches'

require 'cards'
require 'errors/validation_error'

class Response
	attr_accessor :public_message
	attr_reader :private_message
	attr_reader :callbacks

	def initialize(public_message, private_message = nil, callbacks = [])
		@public_message = public_message
		@private_message = private_message
		@callbacks = callbacks
	end
end

class Action
	attr_reader :player

	def initialize(player)
		if self.class.on_perform.nil?
			raise "No 'on_perform' action has been defined for class #{self.class}" 
		end

		@player = player
	end

	class << self
		attr_reader :on_validate
		attr_reader :on_begin
		attr_reader :on_perform

		def on_validate(&block)
			@on_validate = block
		end

		def on_begin(&block)
			@on_begin = block
		end

		def on_perform(&block)
			@on_perform = block
		end

		def respond(message = nil, private: nil, callbacks: [])
			return Response.new(message, private, callbacks)
		end
	end

	def begin(*args)
		if @on_begin
			response = self.class.on_begin.call(@player, *args)
		else
			response = Response.new("")
		end
		response.public_message = "#{player} will #{self}!\n#{response.public_message}"
		response
	end

	def perform(*args)
		@player.lose_coins(self.class.cost) if self.class.cost

		self.class.on_perform.call(@player, *args)
	end

	def validate(*args)
		if self.class.on_validate.nil?	
			self.class.on_validate.call(@player, *args)
		end
		true
	end

	def blockable?
		! Card.blockers(self.class).empty?
	end

	def challengable?
		! Card.actors(self.class).empty? ||
			self.class == Block
	end

	def to_s
		self.class.name.downcase
	end
end

class Income < Action
	on_perform do |player|
		player.gain_coins 1
		respond "#{player} has taken 1 coin as income and now has #{player.coins} coins"
	end

	def to_s
		"take income"
	end
end

class Tax < Action
	on_perform do |player|
		player.gain_coins 3
		respond "#{player} has taken 3 coins as tax and now has #{player.coins} coins"
	end
end

class ForeignAid < Action
	on_perform do |player|
		player.gain_coins 2
		respond "#{player} has taken 2 coins as foreign aid and now has #{player.coins} coins"
	end
end

class Exchange < Action
	on_begin do
		respond private: "When you are ready, pick up two cards by saying 'pickup'"
	end

	on_perform do |player|
		respond "#{player}'s exchange will proceed",
			callbacks: [Pickup.new(player, 2), Return.new(player, 2)]
	end
end

class TargetedAction < Action
	attr_reader :target

	class << self
		attr_reader :cost
		def cost(coins)
			@cost = coins
		end
	end

	def initialize(player, target, cost)
		super(player)
		@target = target
	end

	def validate(*args)
		if @cost && @player.coins >= @cost
			raise ValidationError, "#{@player} only has #{@player.coins} coins! #{@cost} coins are required to #{self}"
		end
		super(@player, @target, *args)
	end

	def begin(*args)
		super(@player, @target, *args)
	end

	def perform(*args)
		super(@player, @target, *args)
	end
end

class Steal < TargetedAction
	on_validate do |player, target|
		if target.coins > 0
			raise ValidationError, "#{target} does not have any coins to steal!"
		end
	end

	on_perform do |player, target|
		coins_taken = player.gain_coins(target.lose_coins(2))
		respond "#{player} took #{coins_taken} coins from #{target}\n" +
			"#{player} now has #{player.coins} coins, and #{target} has #{target.coins}"
	end
end

class Assassinate < TargetedAction
	cost 3

	on_perform do |player, target|
		respond "#{player}'s assassination will proceed!",
			callbacks: [Flip.new(target, 1)]
	end
end

class Coup < TargetedAction
	cost 7

	on_perform do |player, target|
		respond "#{player}'s coup will proceed!",
			callbacks: [Flip.new(target, 1)]
	end
end

class CardAction < Action
	attr_reader :count
	def initialize(player, count = 1)
		super(player)
		@count = count
	end
end

class Pickup < CardAction
	on_perform do |player|
		cards = []
		@count.times do
			cards.push player.gain_card
		end
		respond "#{player} has taken #{@count} card(s) from the deck"
			private: "You've taken #{@count} card(s) from the deck: #{cards.and_join}\n"
	end
end

class Return < CardAction
	on_perform do |player, *cards|
		cards.each do |card|
			player.lose_card card
		end
		respond "#{player} returned #{cards.count} card(s) to the deck",
			private: "You have put back the #{cards.and_join} card(s)"
	end
end

class Flip < CardAction
	on_validate do |player, card|
		unless player.cards.any?{|c| c.class == card.class}
			raise ValidationError, "#{player} does not have a #{card} to flip!"
		end
	end

	on_perform do |player, card|
		player.cards.find{|c| c.is_a? card.class}.flip
		respond "#{player} has revealed the #{card} card!"
	end
end