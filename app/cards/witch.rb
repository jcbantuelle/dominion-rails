class Witch

  def self.starting_count(game)
    10
  end

  def cost
    {
      coin: 5
    }
  end

  def type
    [:action, :attack]
  end

  def play
    # +2 Cards
    # Each other player gains a curse
  end
end
