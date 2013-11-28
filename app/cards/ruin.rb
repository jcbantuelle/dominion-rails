class Ruin < Card

  def starting_count(game)
    case game.player_count
    when 1
      10
    when 2
      10
    when 3
      20
    when 4
      30
    end
  end

end
