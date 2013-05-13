class Adventurer

  def starting_count(game)
    10
  end

  def cost
    [6]
  end

  def type
    [:action]
  end

  def play
    # Reveal cards from deck until you reveal 2 treasure cards. Put treasures in hand, discard rest
  end
end
