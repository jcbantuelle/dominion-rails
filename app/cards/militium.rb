module Militium

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 4
    }
  end

  def type
    [:action, :attack]
  end

  def play
    # +2 Coin
    # Each other player discards down to 3 cards
  end
end
