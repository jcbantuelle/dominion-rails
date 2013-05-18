class Chancellor

  def self.starting_count(game)
    10
  end

  def cost
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
