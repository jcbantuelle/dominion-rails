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

  def coin(game)
    2
  end

  def play(game, clone=false)
    game.current_turn.add_coins(coin(game))
  end

end
