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
    @log_updater.get_from_card(game.current_player, '+1 action')
  end

  def attack(game, player)
    give_card_to_player(game, player, 'curse', 'discard')
  end
end
