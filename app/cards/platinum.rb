module Platinum

  def starting_count(game)
    12
  end

  def cost(game)
    {
      coin: 9
    }
  end

  def type
    [:treasure]
  end

  def play(game, clone=false)
    game.current_turn.add_coins(5)
  end

end
