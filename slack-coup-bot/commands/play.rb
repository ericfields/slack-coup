require 'commands/base'
require 'actions/reactions'

module SlackCoupBot
	module Commands
		class Play < Base

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

				if game.current_action
					raise CommandError, "Another action is currently in progress, #{player}"
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

				Thread.new do
					should_do = true

					if action.blockable? || action.challengable?
						client.say text: "Waiting for reactions...", channel: data.channel

						should_do = countdown(action)

						if should_do
							client.say text: "#{player}'s #{action} will proceed!", channel: data.channel
						end
					end

					if should_do
						execute_stack

						evaluate_game
					end
				end
			end

			match 'block' do |client, data|
				if data.channel[0] == 'D'
					raise CommandError, "Please perform this action in a regular channel, not as a direct message"
				end

				if game.nil?
					raise CommandError, "A game of Coup has not been created. To create a Coup lobby, say 'lobby'"
				elsif ! game.started?
					raise CommandError, "The game has not yet started"
				end

				player = get_player(data.user)

				reaction = class_for_action('block').new(player, game.current_action)

				if game.current_action.nil?
					raise CommandError, "There is no action to #{reaction}"
				elsif game.current_action == reaction
					raise CommandError, "A #{game.current_action} has already been initiated"
				elsif game.current_action.player == player
					raise CommandError, "You cannot #{reaction} your own #{game.current_action}"
				end

				# Check if action is blockable
				if ! game.current_action.blockable?
					raise CommandError, "Cannot block a #{game.current_action}"
				end

				# Check if this player can block
				if game.current_action.is_a?(Actions::TargetedAction) && player != game.current_action.target
					raise CommandError, "Only #{game.current_action.target} can #{reaction} this action"
				end

				client.say text: "#{player} will #{reaction}!", channel: data.channel

				game.stack.push reaction

				Thread.new do

					if countdown(reaction)
						execute_stack

						evaluate_game
					end

				end
			end

			match 'cards' do |client, data|
				player = check_player(data.user)
				next if player.nil?

				whisper data.user, "You have the #{player.remaining_cards} card(s)"
			end

			class << self
				attr_accessor :executing

				def execute_stack
					last_result = nil
					while ! game.stack.empty?
						action = game.stack.pop

						response = action.do *last_result
						logger.info "Executed #{action} action, result: #{response.result}"

						if response.result.is_a? Actions::Cancel
							logger.info "Cancellation received from #{action}, removing actions from stack"
							# Remove the next action (and its subactions) from the stack
							removed_action = nil
							begin
								removed_action = game.stack.pop
								logger.info "Removed '#{removed_action}' from stack"
							end while ! removed_action.is_a? Actions::PlayAction
						else
							last_result = response.result
						end

						print_response response
					end
				end

				def evaluate_game
					return if game.nil? || ! game.started?

					game.players.values.select{|p| ! p.eliminated? }.each do |player|
						if player.remaining_cards.count == 0
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

				def countdown(action)
					logger.info "Waiting for #{action} for #{wait_time} seconds"
					wait_start = Time.now
					begin
						if game.current_action != action
							logger.info "#{action.player}'s #{action} has been interrupted by #{game.current_action}"
							return false
						end
						sleep 0.1
					end while Time.now - wait_start < self.wait_time
					true
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

				def print_response(response)
					self.client.say text: response.public_message, channel: self.channel

					if response.private_message
						whisper response.user.id, response.private_message
					end
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
		end
	end
end