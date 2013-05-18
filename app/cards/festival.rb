class Festival

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
    # +2 actions
    # +1 buy
    # +2 coin
  end
end
