RSpec.configure do |config|
  config.before do
    SlackRubyBot.config.user = 'eric'
  end
end