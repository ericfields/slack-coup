Slack Coup
==========

![Coup](/images/coup.png)

A bot that plays Coup in Slack.

Coup is a board game of revolving around deception, calculation, and remaining the last player standing.
Read more on the rules of Coup [here](https://boardgamegeek.com/boardgame/131357/coup)

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

Run `puma config.ru` to start the bot using the bundled Puma server. You can also set the Slack API token upon starting the server by running `SLACK_API_TOKEN=<your-token-here> puma config.ru`.

## Commands

### Game setup

* `coup-lobby`	- Create a lobby for a game of Coup. Players can join the lobby using *coup-join*
* `coup-join`  	- Join an open Coup lobby.
* `coup-invite`	- Invite other players to a Coup lobby.
* `coup-leave`	- Leave the Coup lobby.
* `coup-kick`		- Remove other players from the Coup lobby.
* `coup-start`	- Start the game of Coup.
* `coup-end`		- End the game of Coup.

#### Debugging

You can start a debugging session for the bot by calling `coup-debug`. This will begin an immediate game with as many players in the channel as are allowed.

You can set the options for the debugging game as environment variables. It would be optimal to set these in the .env file in the root of the source directory. Available options are as follows:

* MIN_PLAYERS				- Minimum number of players in a game. Default is 4.
* MAX_PLAYERS				- Maximum number of players in a game. Default is 6.
* COINS_PER_PLAYER	- Starting coins for each player. Default is 2.
* CARDS_PER_PLAYER	- Starting number of cards for each player. Default is 2.
* SHUFFLE_DECK			- *true* or *false* boolean for whether or not to shuffle the deck. Default is *false* for debugging.
* SHUFFLE_PLAYERS		- *true* or *false* boolean for whether or not to shuffle the player order. Default is *false* for debugging.

### Gameplay

Each player starts the game with two coins and two cards. There are 5 classes of cards, with three of each total, amounting to 15 total cards in the game.

If a player is forced to flip their card, due to an `assassination`, losing a challenge, or a `coup`, they must flip a card. This card remains face up and visible to other players for the duration of the game. When both of a player's cards are flipped, that player is out of the game.

You can get info on any card or action by typing `info <card/action>`.

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

You can check the status of the game as follows:

* `status`			- View each player's number of coins, their revealed cards, and whether or not they are still in the game.
* `cards`				- View your remaining (hidden) cards. You will be sent a direct message describing what cards you have. Can also say `check`.

Once the game has started, the following actions Can only be performed:

* `income`								- Take one coin from the treasury. Can be performed by anyone. Cannot be blocked or challenged.
* `foreign aid`						- Take two coins from the treasury. Can be blocked by a Duke.
* `tax`										- Take three coins from the treasury. Can only be performed by a Duke.
* `exchange`							- Exchange all of your playable cards with cards from the deck. Can only be performed by an Ambassador.
* `steal	<player>`				- Steal two coins from another player. Can only be performed by a Captain. Blocked by Captain or Ambassador.
* `assassinate <player>`	- Costs 3 coins. Force one player to flip a card. Can only be performed by an Assassin. Blocked by Contessa.
* `coup <player>`					- Costs 7 coins. Force one player to flip a card. Cannot be blocked. **Note**: When a player starts a turn with 10 or more coins, they must perform a coup.

Once a player performs an action, other players can choose to react as follows:

* `block`									- Block the previous action. Like all actions, any player can perform a block (if the action can be blocked). However, if the player does not have a card that is capable of blocking the action, that player may lose a card if another play decides to `challenge` their block.
* `challenge`							- Challenge another player's action. Force a player to reveal a card. If that card is not capable of the action/block that the player has performed, that player loses the card. However, if that card can perform the action/block, the player who issued the challenge loses a card, and the challenged player exchanges the flipped card for a new one from the deck.
* `okay`										- Allow the player's action to be performed. Only the next player in the turn order, or the player that is being targeted if it is a targeted action/reaction, can give the `okay`. Also aliased as `ok`, or `k`.

When these actions are performed, CoupBot may prompt the user to provide further input as follows:
* `flip <card>`								- Flip and reveal a card.
* `return <card1> (<card2>)`	- Return one or more cards to the deck. You can (and should) send this as a direct message to the bot, to prevent other players from knowing.

## Copyright/License

Copyright© 2016 Eric Fields

[Twitter](https://twitter.com/CptEric)

[Email](mailto:ericfields09@gamil.com)

This project is licensed under the [MIT license](LICENSE.md).

Coup™ and all registered trademarks are owned by [Indie Boards and Cards](http://www.indieboardsandcards.com/).

