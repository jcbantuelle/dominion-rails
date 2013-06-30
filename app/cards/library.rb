module Library

  def starting_count(game)
    10
  end

  def cost
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play
    # Draw until you have 7 cards in hand, you may set aside action cards drawn as you draw them. Discard set aside cards.
  end
end
