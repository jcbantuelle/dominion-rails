module Platinum

  def starting_count(game)
    12
  end

  def cost(game, turn)
    {
      coin: 9
    }
  end

  def type
    [:treasure]
  end

  def coin
    5
  end

  def play(game, clone=false)
    game.current_turn.add_coins(coin)
  end

end
