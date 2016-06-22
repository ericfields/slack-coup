require 'commands/base'
require 'actions/reactions'

module SlackCoupBot
	module Commands
		class Play < Base

			class << self
				def print_response(response)
					self.client.say text: response.public_message, channel: self.channel

					if response.private_message
						whisper response.user.id, response.private_message
					end
				end

				def evaluate_game
					return if game.nil? || ! game.started?

					game.players.values.select{|p| ! p.eliminated? }.each do |player|
						if player.remaining_cards == 0
							self.logger.info "#{player} has cards #{player.cards} - #{player.remaining_cards} are flipped and #{player} is out of the game"
							player.eliminate
							self.client.say text: "#{player} is out of the game!", channel: self.channel
						end
					end

					if game.remaining_players == 1
						winner = game.players.values.find{|p| ! p.eliminated? }
						self.client.say text: "#{winner} has won the game!"
						end_game
					else
						game.advance
						self.client.say text: "It is now #{game.current_player}'s turn to act", channel: self.channel
					end
				end

				def get_player(user)
					player = game.players[user]
					if player.nil?
						raise CommandError, "You are not in the game!"
					elsif player.eliminated?
						raise CommandError, "You have already been eliminated from the game, #{player}."
					end
					player
				end

				def class_for_action(action_name)
					action_name = 'SlackCoupBot::Actions::' + action_name.to_s.split(' ').map(&:capitalize).join
					begin
						Object.const_get(action_name)
					rescue NameError
						raise InternalError, "#{action_name} does not map to a recognized class"
					end
				end

				def class_for_card(card_name)
					card_name = 'SlackCoupBot::Cards::' + card_name.to_s.capitalize
					begin
						Object.const_get(card_name)
					rescue NameError
						raise CommandError, "#{card_name} is not a card!"
					end
				end

				def add_player(user)
					game.add_player user
				end

				def remove_player(user)
					removed_player = game.remove_player user
					if removed_player.nil?
						raise CommandError, "#{subject} not in the game."
					end
				end
			end

			match /(?<action>income|tax|foreign aid)/ do |client, data, match|
				if data.channel[0] == 'D'
					raise CommandError, "Please perform this action in a regular channel, not as a direct message"
				end

				if game.nil?
					raise CommandError, "A game of Coup has not been created. To create a Coup lobby, say 'lobby'"
				elsif ! game.started?
					raise CommandError, "The game has not yet started"
				end

				player = get_player(data.user)

				# Check turn
				if player != game.current_player
					raise CommandError, "It is not your turn, #{player}!"
				end

				action = class_for_action(match[:action]).new(player)

				action.validate

				# Push action along with subactions onto stack
				game.stack.push action
				action.subactions.reverse.each do |subaction|
					game.stack.push subaction
				end

				self.logger.info "Current game stack: #{game.stack.show}"

				client.say text: "#{player} will take #{action}!", channel: data.channel

				should_do = true

				if action.blockable? || action.challengable?
					client.say text: "Waiting for reactions...", channel: data.channel
					wait_start = Time.now

					begin
						if game.stack.last.is_a? Actions::Reaction
							should_do = false
							break
						end
						sleep 1
					end while Time.now - wait_start < self.wait_time
					if should_do
						client.say text: "#{player}'s #{action} will proceed!", channel: data.channel
					end
				end

				if should_do
					last_result = nil
					while ! game.stack.empty?
						action = game.stack.pop

						response = action.do *last_result
						last_result = response.result

						print_response response
					end

					evaluate_game
				end
			end

			match 'cards' do |client, data|
				player = check_player(data.user)
				next if player.nil?

				whisper
			end
		end
	end
end