module Copper

  def starting_count(game)
    60
  end

  def cost
    {
      coin: 0
    }
  end

  def type
    [:treasure]
  end

  def play
    # +1 coin
  end
end
