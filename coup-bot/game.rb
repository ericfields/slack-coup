require 'users'
require 'actions'
require 'cards'
require 'errors'
require 'player'
require 'patches'

class Game
	include Users

	attr_accessor :players
	attr_accessor :deck

	attr_reader :started

	attr_accessor :current_action

	def initialize(channel)
		@channel = channel
		# Create a deck of cards, with 3 of each role
		@players = {}
		@deck = []

		[Assassin, Ambassador, Captain, Contessa, Duke].each do |role_class|
			3.times do
				@deck.push role_class.new
			end
		end
	end

	def add_player(user)
		name = name_for(user)
		@players[user] = Player.new(self, user, name)
	end

	def remove_player(user)
		@players.delete user
	end

	def player_list
		@players.values.collect{|player| player.name}.join("\n")
	end

	def start
		@deck.shuffle	# Ruby built-in
		
		@players = Hash[@players.to_a.shuffle] # Randomize the order of players

		players.each do |player|
			2.times do
				player.take_card @deck.shift
			end
		end

		@current_player = 0
		@started = true
	end

	def started?
		@started
	end
end