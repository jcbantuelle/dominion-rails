module Mine

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play
    # Trash a treasure, gain a treasure costing up to 3 more
  end
end
