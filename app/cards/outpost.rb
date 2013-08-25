module Outpost

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 5
    }
  end

  def type
    [:action, :duration]
  end

  def play(game)
  end

  def duration(game)
  end

end
