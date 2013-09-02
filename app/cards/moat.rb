module Moat

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 2
    }
  end

  def type
    [:action, :reaction]
  end

  def play
    # +2 Cards
  end

  def reaction
    # Unaffected by Attack
  end
end
