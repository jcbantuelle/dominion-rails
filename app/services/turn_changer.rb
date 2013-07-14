class TurnChanger

  def self.first_turn(game)
    game.update_attribute :turn, 1
    Turn.create game_player: game.game_players.first, game: game, turn: 1, actions: 1, buys: 1, coins: 0
  end

  def self.next_turn(game)
    game.update_attribute :turn, game.turn + 1
    Turn.create game_player: self.next_player(game), game: game, turn: 1, actions: 1, buys: 1, coins: 0
  end

  private

  def self.next_player(game)
    turn = (game.turn % game.player_count) - 1
    game.game_players[turn]
  end

end
