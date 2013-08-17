module Moneylender

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play
    # Trash a Copper from hand
    # If you do, +3 coin
  end
end
