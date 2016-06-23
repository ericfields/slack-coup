require 'commands/base'
require 'actions/reactions'

module SlackCoupBot
	module Commands
		class Play < Base

			match /(?<action>income|tax|foreign aid|exchange)/ do |client, data, match|
				logger.info "Passive action requested: #{match[:action]}"

				if data.channel[0] == 'D'
					raise CommandError, "Please perform this action in a regular channel, not as a direct message"
				end

				next if game.nil? || ! game.started?

				player = get_player(data.user)
				if player.nil?
					raise CommandError, "You are not in the game!"
				elsif player.eliminated?
					raise CommandError, "You have already been eliminated from the game, #{player}."
				end

				# Check turn
				if player != game.current_player
					raise CommandError, "It is not your turn, #{player}!"
				end

				if game.current_player_action
					raise CommandError, "Another action is currently in progress, #{player}"
				end

				action = class_for_action(match[:action]).new(player)

				action.validate

				# Push action along with subactions onto stack
				load_actions action

				sleep message_delay
				client.say text: "#{player} will take #{action}!", channel: data.channel

				async do
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

			match /^(?<action>steal|assassinate|coup)( (?<target>[\w-]+)?)?\s*$/ do |client, data, match|
				logger.info "Aggressive action requested: #{match[:action]}"

				if data.channel[0] == 'D'
					raise CommandError, "Please perform this action in a regular channel, not as a direct message"
				end

				if match[:target].nil?
					raise CommandError, "You must specify a target for a #{match[:action]}!"
				end

				next if game.nil? || ! game.started?

				player = get_player(data.user)
				if player.nil?
					raise CommandError, "You are not in the game!"
				elsif player.eliminated?
					raise CommandError, "You have already been eliminated from the game, #{player}."
				end

				# Check turn
				if player != game.current_player
					raise CommandError, "It is not your turn, #{player}!"
				end

				if game.current_player_action
					raise CommandError, "Another action is currently in progress, #{player}"
				end

				target_user = User.with_name(match[:target])
				if target_user.nil?
					raise CommandError, "User #{match[:target]} is not present in this channel."
				end

				target = get_player(target_user.id)
				if target.nil?
					raise CommandError, "#{target_user} is not in the game!"
				elsif player.eliminated?
					raise CommandError, "#{target_user} has already been eliminated from the game, #{player}."
				end

				action = class_for_action(match[:action]).new(player, target)
				action.validate

				load_actions action

				sleep message_delay
				client.say text: "#{player} will #{action} #{target}!", channel: data.channel

				async do
					should_do = true

					if action.blockable? || action.challengable?
						client.say text: "Waiting for reaction from #{target}...", channel: data.channel

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

			match /(?<reaction>block|challenge)/ do |client, data, match|
				logger.info "Reaction requested: #{match[:reaction]}"
				
				if data.channel[0] == 'D'
					raise CommandError, "Please perform this action in a regular channel, not as a direct message"
				end

				next if game.nil? || !game.started?

				player = get_player(data.user)
				if player.nil?
					raise CommandError, "You are not in the game!"
				elsif player.eliminated?
					raise CommandError, "You have already been eliminated from the game, #{player}."
				end

				if game.current_action.nil?
					raise CommandError, "There is no action to #{match[:reaction]}"
				end

				reaction = class_for_action(match[:reaction]).new(player, game.current_player_action)

				if game.executing?
					raise CommandError, "You can no longer #{reaction} #{game.current_player_action.player}'s #{game.current_player_action}. #{game.current_action.player} must #{game.current_action}."
				elsif game.current_player_action.nil?
					raise CommandError, "There is no action to #{reaction}"
				elsif game.current_player_action == reaction
					raise CommandError, "A #{game.current_player_action} has already been initiated"
				end

				reaction.validate

				sleep message_delay
				client.say text: "#{player} will #{reaction}!", channel: data.channel

				load_actions reaction

				if reaction.challengable?
					async do
						if countdown(reaction)
							execute_stack

							evaluate_game
						end
					end
				else
					execute_stack
					evaluate_game
				end
			end

			match /(?<subaction>flip|return)( (?<cards>[\w\s]+))?/ do |client, data, match|
				logger.info "Sub action requested: #{match[:subaction]}"

				next if game.nil? || !game.started?

				player = get_player(data.user)
				next if player.nil? || player.eliminated?

				if match[:cards].nil?
					raise CommandError, "You must specify one or more cards to #{match[:subaction]}"
				end

				card_names = match[:cards].split(' ')
				cards = card_names.collect do |card_name|
					class_for_card(card_name).new
				end

				subaction = class_for_action(match[:subaction]).new(player, *cards)
				if subaction != game.current_action
					logger.info "Action #{subaction} does not match action #{game.current_action}"
					raise CommandError, "Now is not the time to #{subaction}, #{player}"
				end

				subaction.validate *cards

				execute_stack(cards)

				evaluate_game
			end

			match /check|cards/ do |client, data|
				logger.info "Card check action requested"

				player = get_player(data.user)
				next if player.nil?

				if player.remaining_cards.count == 0
					whisper data.user, "You do not have any cards. You are out of the game."
				else
					whisper data.user, "You have the #{player.remaining_cards} card(s)"
				end
			end

			class << self
				def execute_stack(user_input = nil)
					action_input = user_input
					game.begin_execution

					while ! game.stack.empty?
						logger.info "Initiating execution flow: Current game stack: #{game.stack.show}"
						sleep message_delay

						# Check if action requires user input
						if game.current_action.is_a? Actions::SubAction
							if game.current_action.prompt && user_input.nil?
								logger.info "User input is required for #{game.current_action} action, notifying #{game.current_action.player}"
								# Stop exeucting stack and wait for user to provide input
								print_response game.current_action.prompt
								return false
							end
						end

						action = game.stack.pop

						logger.info "Executing #{action} action from the stack"
						response = action.do *action_input

						logger.info "Performed #{action}. Result: #{response.result || 'nil'}"

						result = response.result

						if result.is_a? Actions::Cancel
							logger.info "Cancellation received from #{action}, removing actions from stack"
							action_to_cancel = result.action
							# Remove the next action (and its subactions) from the stack
							removed_action = nil
							begin
								removed_action = game.stack.pop
								if removed_action.nil?
									raise InternalError, "Tried to remove results from stack as part of Cancel but stack is now empty. Action to cancel: #{action_to_cancel}"
								end

								logger.info "Removed '#{removed_action}' from stack"
							end while removed_action != action_to_cancel
						else
							action_input = response.result
						end

						unless response.new_actions.empty?
							load_actions *(response.new_actions)
						end

						print_response response

						game.end_execution
						true
					end
				end

				def async(&block)
					Thread.new do
						begin
							yield
						rescue CoupError => e
							self.client.say text: e.message, channel: self.channel
						rescue => e
							self.client.say text: "Internal error", channel: self.channel
							logger.error "#{e.class}: #{e.message}. Backtrace:\n\t#{e.backtrace.join("\n\t")}"
						end
					end
				end

				def load_actions(*actions)
					actions.reverse.each do |action|
						game.stack.push action
						if action.is_a? Actions::PlayAction
							action.subactions.reverse.each do |subaction|
								game.stack.push subaction
							end
						end
						logger.info "Action #{action} has been pushed onto the game stack. Current game stack: #{game.stack.show}"
					end
				end

				def evaluate_game
					return if game.nil? || ! game.started?

					# If there are still actions on the stack, the game state should not be evaluated
					return if ! game.stack.empty?

					game.players.values.select{|p| ! p.eliminated? }.each do |player|
						if player.remaining_cards.count == 0
							self.logger.info "#{player} has cards #{player.cards} - all of player's cards are flipped and #{player} is out of the game"
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

					logger.info ""
				end

				def countdown(action)
					logger.info "Waiting for #{action} for #{reaction_time} seconds"
					wait_start = Time.now
					begin
						if game.current_player_action != action
							logger.info "#{action.player}'s #{action} has been interrupted by #{game.current_player_action}"
							return false
						end
						sleep 0.1
					end while Time.now - wait_start < self.reaction_time
					true
				end

				def get_player(user)
					if game.nil?
						raise CommandError, "There is no game in-progress"
					end
					game.players[user]
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
					card_name = card_name.to_s.capitalize
					begin
						Object.const_get('SlackCoupBot::Cards::' + card_name)
					rescue NameError
						raise CommandError, "#{card_name} is not a card!"
					end
				end
			end
		end
	end
end