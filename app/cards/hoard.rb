module Hoard

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 6
    }
  end

  def type
    [:treasure]
  end

  def play(game)
    game.current_turn.add_coins(2)
    game.current_turn.add_hoard
  end

end
