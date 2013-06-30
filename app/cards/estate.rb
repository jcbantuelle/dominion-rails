module Estate

  def starting_count(game)
    game.player_count < 3 ? 8 : 12
  end

  def cost
    {
      coin: 2
    }
  end

  def type
    [:victory]
  end

  def value(deck)
    1
  end
end
