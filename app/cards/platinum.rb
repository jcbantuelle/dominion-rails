class Platinum < Card

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

  def coin(game)
    5
  end

  def play(game, clone=false)
    game.current_turn.add_coins(coin(game))
  end

end
