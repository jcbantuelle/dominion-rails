module Woodcutter

  def starting_count(game)
    10
  end

  def cost
    {
      coin: 3
    }
  end

  def type
    [:action]
  end

  def play
    # +1 Buy
    # +2 Coin
  end
end
