module SlackRubyBot
  module Commands
    class HelpCommand < Base

      # Refactoring 'help' command to respond to non-direct messages
      match /^(coup-)?help( (?<subject>))?$/ do |client, data, match|
        command = match[:subject]

        text = if command.present?
                 CommandsHelper.instance.command_full_desc(command)
               else
                 general_text
               end

        client.say(channel: data.channel, text: text, gif: 'help')
      end

      class << self
        private

        def general_text
          bot_desc = CommandsHelper.instance.bot_desc_and_commands
          other_commands_descs = CommandsHelper.instance.other_commands_descs
          <<TEXT
#{bot_desc.join("\n")}

*Other commands:*
#{other_commands_descs.join("\n")}

For getting description of the command use: *help <command>*

For more information see https://github.com/ericfields/slack-coup-bot.
TEXT
        end
      end
    end
  end
end