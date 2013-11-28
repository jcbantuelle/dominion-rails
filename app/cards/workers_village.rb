class WorkersVillage < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(1)
    game.current_turn.add_actions(2)
    game.current_turn.add_buys(1)
    @log_updater.get_from_card(game.current_player, '+2 actions and +1 buy')
  end

end
