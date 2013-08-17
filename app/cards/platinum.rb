module Platinum

  def starting_count(game)
    12
  end

  def cost
    {
      coin: 9
    }
  end

  def type
    [:treasure]
  end

  def play(game)
    game.current_turn.add_coins(5)
  end

  def log(game, player)
    render_play_card game, player
  end
end
