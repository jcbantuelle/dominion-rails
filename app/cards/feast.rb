module Feast

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
    # Trash Card
    # Gain Card costing up to 5
  end
end
