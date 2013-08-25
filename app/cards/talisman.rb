module Talisman

  def starting_count(game)
    10
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
    game.current_turn.add_coins(1)
    game.current_turn.add_talisman
  end

end
