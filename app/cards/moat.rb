module Moat

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 2
    }
  end

  def type
    [:action, :reaction]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(2)
  end

end
