module Gold

  def starting_count(game)
    30
  end

  def cost(game, turn)
    {
      coin: 6
    }
  end

  def type
    [:treasure]
  end

  def coin(game)
    3
  end

  def play(game, clone=false)
    game.current_turn.add_coins(coin(game))
  end

end
