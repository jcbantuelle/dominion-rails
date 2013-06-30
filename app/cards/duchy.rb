module Duchy

  def starting_count(game)
    game.player_count < 3 ? 8 : 12
  end

  def cost
    {
      coin: 5
    }
  end

  def type
    [:victory]
  end

  def value(deck)
    3
  end
end
