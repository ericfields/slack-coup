require 'user'
require 'player'
require 'cards'

require 'errors'

module SlackCoupBot
	class Game
		include Cards

		attr_accessor :players
		attr_accessor :deck

		attr_reader :started

		attr_accessor :stack
		attr_accessor :executing

		def initialize(channel, 
			coins_per_player: 2,
			cards_per_player: 2,
			shuffle_deck: true,
			shuffle_players: true)
			@channel = channel
			# Create a deck of cards, with 3 of each role
			@players = {}
			@deck = []

			@stack = []
			@executing = false

			@coins_per_player = coins_per_player
			@cards_per_player = cards_per_player
			@shuffle_players = shuffle_players
			@shuffle_deck = shuffle_deck

			3.times do
				[Assassin, Ambassador, Captain, Contessa, Duke].each do |role_class|
					@deck.push role_class.new
				end
			end

			@player_index = 0

			@logger = SlackRubyBot::Client.logger
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

		def status
			status_str = ""
			@players.values.each do |player|
				player_strs = []
				if player.eliminated?
					player_strs << "#{player} (eliminated)"
				else
					player_strs << "#{player}"
					player_strs << "#{player.coins} coins"
				end

				card_strs = []
				player.cards.each do |card|
					if card.flipped?
						card_strs << "#{card}"
					end
				end
				unless card_strs.empty?
					player_strs << "#{card_strs}"
				end

				status_str << player_strs.join('  -  ') + "\n"
			end
			status_str
		end

		def start
			if @players.count < 4
				raise CommandError, "Cannot start a game with less than 4 players"
			end
			
			@players.values.each do |player|
				player.gain_coins @coins_per_player
			end

			if @shuffle_deck
				@deck.shuffle!	# Ruby built-in
			end
			if @shuffle_players
				@players = Hash[@players.to_a.shuffle] # Randomize the order of players
			end

			players.values.each do |player|
				@cards_per_player.times do
					player.gain_card
				end
			end

			@current_player = 0
			@started = true
		end

		def return_to_deck(card)
			card.hide
			@deck.push card
			if @shuffle_deck
				@deck.shuffle!
			end
		end

		def take_from_deck
			@deck.shift
		end

		def current_player
			@players.values.at @player_index
		end

		def current_player_action
			@stack.reverse.find{|action| action.is_a? Actions::PlayAction}
		end

		def current_action
			@stack.last
		end

		def begin_execution
			@executing = true
		end

		def end_execution
			@executing = false
		end

		def executing?
			@executing
		end

		def advance
			begin
				@player_index = (@player_index + 1) % @players.count
			end while @players.values.at(@player_index).eliminated?
		end

		def remaining_players
			@players.values.count{|player| ! player.eliminated? }
		end

		def started?
			@started
		end
	end
end