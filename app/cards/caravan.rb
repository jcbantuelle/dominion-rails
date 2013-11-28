module Caravan

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:action, :duration]
  end

  def play(game, clone=false)
    card_drawer = CardDrawer.new(game.current_player)
    card_drawer.draw(1)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')
  end

  def duration(game)
    CardDrawer.new(game.current_player).draw_duration(1, self)
  end

end
