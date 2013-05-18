class Village

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
    # +1 Card
    # +2 Action
  end
end
