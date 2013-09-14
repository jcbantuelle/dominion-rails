module Potion

  def starting_count(game)
    16
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:treasure]
  end

  def play(game, clone=false)
    game.current_turn.add_potions(1)
  end

end
