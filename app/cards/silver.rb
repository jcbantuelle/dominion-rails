module Silver

  def starting_count(game)
    40
  end

  def cost(game, turn)
    {
      coin: 3
    }
  end

  def type
    [:treasure]
  end

  def coin
    2
  end

  def play(game, clone=false)
    game.current_turn.add_coins(coin)
  end

end
