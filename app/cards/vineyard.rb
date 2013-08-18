module Vineyard

  def starting_count(game)
    game.player_count == 2 ? 8 : 12
  end

  def cost(game)
    {
      coin: 0,
      potion: 1
    }
  end

  def type
    [:victory]
  end

  def value(deck)
    deck.select(&:action?).count / 3
  end
end
