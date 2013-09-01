module GreatHall

  def starting_count(game)
    victory_card_count(game)
  end

  def cost(game)
    {
      coin: 3
    }
  end

  def type
    [:action, :victory]
  end

  def value(deck)
    1
  end

  def play(game, clone=false)
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(1)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')
  end

  def results(deck)
    card_html
  end

end
