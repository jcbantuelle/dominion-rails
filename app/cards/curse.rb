module Curse

  def starting_count(game)
    case game.player_count
    when 2
      10
    when 3
      20
    when 4
      30
    end
  end

  def cost
    {
      coin: 0
    }
  end

  def type
    [:curse]
  end

  def value(deck)
    -1
  end
end
