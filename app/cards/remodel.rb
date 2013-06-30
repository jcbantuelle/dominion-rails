module Remodel

  def starting_count(game)
    10
  end

  def cost
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play
    # Trash Card
    # Gain Card costing up to 2 more than trashed card
  end
end
