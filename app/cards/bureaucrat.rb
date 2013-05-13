class Bureaucrat

  def starting_count(game)
    10
  end

  def cost
    [4]
  end

  def type
    [:action, :attack]
  end

  def play
    # Gain a Silver on top of deck
    # Each Other Player reveals a victory card from hand and puts on top of deck (or reveals hand with no victory cards)
  end
end
