module Familiar

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 3,
      potion: 1
    }
  end

  def type
    [:action, :attack]
  end

  def play(game)
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(1)

    game.current_turn.add_actions(1)

    give_card_to_players(game, 'curse', 'discard')
  end
end
