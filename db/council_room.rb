class CouncilRoom

  def starting_count(game)
    10
  end

  def cost
    [5]
  end

  def type
    [:action]
  end

  def play
    # +4 cards
    # +1 buy
    # Each other player draws 1 card
  end
end
