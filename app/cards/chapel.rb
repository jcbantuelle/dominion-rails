class Chapel

  def self.starting_count(game)
    10
  end

  def cost
    {
      coin: 2
    }
  end

  def type
    [:action]
  end

  def play
    # Trash up to 4 cards
  end
end
