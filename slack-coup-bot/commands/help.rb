require 'actions/play_actions'

module SlackRubyBot
  class CommandsHelper
    def bot_desc_and_commands(category = nil)
      collect_help_attrs(bot_help_attrs) do |help_attrs|
        bot_commands_descs = collect_name_and_desc(help_attrs.commands.select{|c| category.nil? ? true : c.category == category})
        name_and_desc = category == :general ? command_name_and_desc(help_attrs) : nil
        category_desc = category ? category.to_s.capitalize : 'Commands'
        "#{name_and_desc}\n\n*#{category_desc}:*\n#{bot_commands_descs.join("\n")}"
      end
    end


    def command_full_desc(name)
      unescaped_name = Slack::Messages::Formatting.unescape(name)
      help_attrs = find_command_help_attrs(unescaped_name)
      return nil unless help_attrs
      return "There's no description for command *#{unescaped_name}*" if help_attrs.command_long_desc.blank? && help_attrs.command_desc.blank?
      command_desc_str = "#{command_name_and_desc(help_attrs)}"
      unless help_attrs.command_long_desc.blank?
        command_desc_str += "\n\n#{help_attrs.command_long_desc}"
      end
      command_desc_str
    end

    def find_command_help_attrs(name)
      help_attrs = commands_help_attrs.find { |k| k.command_name.downcase == name.downcase }
      return help_attrs if help_attrs
      commands_help_attrs.each { |k| k.commands.each { |c| return c if c.command_name.downcase == name.downcase } }
      nil
    end
  end
  module Commands

    module Help
      class Attrs
        attr_reader :category

        def initialize(class_name, category = :general)
          @class_name = class_name
          @commands = []
          @category = category
        end

        def command(title, category = :general, &block)
          @commands << self.class.new(class_name, category).tap do |k|
            k.title(title)
            k.instance_eval(&block)
          end
        end
      end
    end

    class HelpCommand < Base

      # Refactoring 'help' command to respond to non-direct messages
      match /^(game )?help( (?<subject>\w+([-\s]\w+)?))?$/i do |client, data, match|
        command = match[:subject]

        text = if command.present?
                 CommandsHelper.instance.command_full_desc(command.downcase)
               else
                 general_text
               end

        if text
          client.say(channel: data.channel, text: text)
        end
      end

      class << self
        private

        def general_text
          bot_desc = CommandsHelper.instance.bot_desc_and_commands(:general)
          action_desc = CommandsHelper.instance.bot_desc_and_commands(:actions)
          card_desc = CommandsHelper.instance.bot_desc_and_commands(:cards)

          <<TEXT
#{bot_desc.join("\n")}

#{action_desc.join("\n")}

#{card_desc.join("\n")}

For a more detailed description of any command, use: *help <command>*

For more info about the game, visit https://github.com/ericfields/slack-coup-bot.
TEXT
        end
      end
    end
  end
end