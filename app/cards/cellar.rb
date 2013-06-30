module Cellar

  def starting_count(game)
    10
  end

  def cost
    {
      coin: 2
    }
  end

  def type
    [:action]
  end

  def play
    # +1 Action
    # Discard any number of cards, +1 Card per discarded
  end
end
