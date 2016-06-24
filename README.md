Slack Coup
==========

A bot that plays Coup in Slack.

Coup is a board game of revolving around deception, calculation, and remaining the last player standing.
Read more on the rules of Coup here:
https://boardgamegeek.com/boardgame/131357/coup

This bot is built on top of the [slack-ruby-bot](https://github.com/dblock/slack-ruby-bot) library.

## Installation

Slack Coup requires Ruby 2.1 or higher. Using a Ruby verion manager, such as [rvm](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv), is recommended.

### Bundler

Ensure that Bundler is installed bundler via RubyGems, by running `gem install bundler`.

In the source directory, run `bundle install` to install the gems for the project.

### Bot User

Create a Slack bot user for your Slack team, with a generated API token. See [here](https://api.slack.com/tokens).

Once the API token is generated, you can set it as an environment variable in the .env file at the root of the source directory. Simply create a file called .env with a single line, `SLACK_API_TOKEN=<your-token-here>`

### Development server

Run `foreman start` to start a development server. You can also set the Slack API token upon starting the server by running `SLACK_API_TOKEN=<your-token-here> foreman start`.

## Commands

### Game setup

* `coup-lobby`	- Create a lobby for a game of Coup. Players can join the lobby using *coup-join*
* `coup-join`  	- Join an open Coup lobby.
* `coup-invite`	- Invite other players to a Coup lobby.
* `coup-leave`	- Leave the Coup lobby.
* `coup-kick`		- Remove other players from the Coup lobby.
* `coup-start`	- Start the game of Coup.
* `coup-end`		- End the game of Coup.

### Gameplay

Each player starts the game with two coins and two cards. There are 5 classes of cards, with three of each total, amounting to 15 total cards in the game.

If a player is forced to flip their card, due to an `assassination`, losing a challenge, or a `coup`, they must flip a card. This card remains face up and visible to other players for the duration of the game. When both of a player's cards are flipped, that player is out of the game.

#### Cards

##### Ambassador
Allows player to `exchange` their cards. Blocks `steal`.

##### Duke
Allows player to `tax`. Blocks `foreign aid`.

##### Captain
Allows player to `steal` two coins from another player. Blocks `steal`.

##### Assassin
Allows player to `assassinate` another player.

##### Contessa
Blocks `assassinate`.

#### Actions

Any player can perform any action, at any time. However, if that player does not have a card that supports the action, the player can lose a card if another player decides to `challenge` their action.

Once the game has started, the following actions Can only be performed:

* `income`								- Take one coin from the treasury. Can be performed by anyone. Cannot be blocked or challenged.
* `foreign aid`						- Take two coins from the treasury. Can be blocked by a Duke.
* `tax`										- Take three coins from the treasury. Can only be performed by a Duke.
* `exchange`							- Exchange all of your playable cards with cards from the deck. Can only be performed by an Ambassador.
* `steal	<player>`				- Steal two coins from another player. Can only be performed by a Captain. Blocked by Captain or Ambassador.
* `assassinate <player>`	- Costs 3 coins. Force one player to flip a card. Can only be performed by an Assassin. Blocked by Contessa.
* `coup`									- Costs 7 coins. Force one player to flip a card. Cannot be blocked. **Note**: When a player starts a turn with 10 or more coins, they must perform a coup.

Additionally, the following reactions may be performed after another player performs an action:

* `block`									- Block the previous action. Like all actions, any player can perform a block (if the action can be blocked). However, if the player does not have a card that is capable of blocking the action, that player may lose a card if another play decides to `challenge` their block.
* `challenge`							- Challenge another player's action. Force a player to reveal a card. If that card is not capable of the action/block that the player has performed, that player loses the card. However, if that card can perform the action/block, the player who issued the challenge loses a card, and the challenged player exchanges the flipped card for a new one from the deck.

When these actions are performed, CoupBot may prompt the user to provide further input as follows:
* `flip <card>`								- Flip and reveal a card.
* `return <card1> (<card2>)`	- Return one or more cards to the deck.
