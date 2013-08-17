module ThroneRoom

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
    # Choose an action in hand, play it twice
  end
end
