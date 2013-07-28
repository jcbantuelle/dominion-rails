module Woodcutter

  def starting_count(game)
    10
  end

  def cost
    {
      coin: 3
    }
  end

  def type
    [:action]
  end

  def play(game)
    game.current_turn.add_coins(2)
    game.current_turn.add_buys(1)
  end

  def log(game, player)
    message = game.current_player.player_id == player.id ? 'You play' : "#{game.current_player.username} plays"
    message += " a <span class=\"#{type_class}\">Woodcutter</span> getting +1 buy and +$2."
  end
end
