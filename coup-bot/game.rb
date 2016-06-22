require 'user'
require 'cards'
require 'errors'
require 'player'

class Game

	attr_accessor :players
	attr_accessor :deck

	attr_reader :started

	attr_accessor :stack

	def initialize(channel, debug = false)
		@channel = channel
		# Create a deck of cards, with 3 of each role
		@players = {}
		@deck = []

		@stack =[]

		@debug = debug

		[Assassin, Ambassador, Captain, Contessa, Duke].each do |role_class|
			3.times do
				@deck.push role_class.new
			end
		end

		@player_index = 0
	end

	def add_player(user)
		if @players.count >= 6
			raise CommandError, "Coup can only be played with a maximum of 6 players.\n\nCurrent players:\n\n#{player_list}"
		end
		user = User.find(user) if user.is_a? String
		@players[user.id] = Player.new(self, user)
	end

	def remove_player(user)
		@players.delete user
		@player_index -= 1
	end

	def player_list
		@players.values.join("\n")
	end

	def start
		if @players.count < 4
			raise CommandError, "Cannot start a game with less than 4 players"
		end

		@deck.shuffle!	# Ruby built-in
		
		unless @debug
			@players = Hash[@players.to_a.shuffle] # Randomize the order of players
		end

		players.values.each do |player|
			2.times do
				player.gain_card
			end
		end

		@current_player = 0
		@started = true
	end

	def current_player
		@players.values.at @player_index
	end

	def advance
		begin
			@player_index = (@player_index + 1) % remaining_players
		end while @players.values.at(@player_index).eliminated?
	end

	def remaining_players
		@players.values.count{|player| ! player.eliminated? }
	end

	def started?
		@started
	end
end