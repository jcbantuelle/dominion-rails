module Chancellor

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 3
    }
  end

  def type
    [:action]
  end

  def play
    # +2 Coin
    # May Put Deck in Discard
  end
end
