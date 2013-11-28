class Outpost < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action, :duration]
  end

  def play(game, clone=false)
  end

  def duration(game)
  end

end
