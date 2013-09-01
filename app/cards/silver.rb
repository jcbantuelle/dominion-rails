module Silver

  def starting_count(game)
    40
  end

  def cost(game)
    {
      coin: 3
    }
  end

  def type
    [:treasure]
  end

  def play(game, clone=false)
    game.current_turn.add_coins(2)
  end

end
