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
    locals = {
      get_text: '+1 buy and +$2'
    }
    render_play_card game, player, locals
  end
end
