module Laboratory

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    game.current_turn.add_actions(1)
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(2)
    @log_updater.get_from_card(game.current_player, '+1 action')
  end

end
