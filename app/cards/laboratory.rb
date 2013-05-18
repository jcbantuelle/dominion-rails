class Laboratory

  def self.starting_count(game)
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
    # +2 cards
    # +1 action
  end
end
