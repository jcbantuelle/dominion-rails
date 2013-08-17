module Potion

  def starting_count(game)
    16
  end

  def cost(game)
    {
      coin: 4
    }
  end

  def type
    [:treasure]
  end

  def play(game)
    #game.current_turn.add_coins(3)
  end

  def log(game, player)
    render_play_card game, player
  end
end
