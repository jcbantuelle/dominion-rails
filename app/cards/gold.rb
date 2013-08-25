module Gold

  def starting_count(game)
    30
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
    game.current_turn.add_coins(3)
  end

end
