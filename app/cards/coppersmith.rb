module Coppersmith

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    game.current_turn.add_coppersmith
  end

end
