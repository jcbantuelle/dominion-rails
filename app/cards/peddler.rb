module Peddler

  def starting_count(game)
    10
  end

  def cost(game)
    coin = 8
    coin -= (game.current_turn.played_actions * 2) if game.current_turn.present? && game.current_turn.buy_phase?
    coin = 0 if coin < 0
    {
      coin: coin
    }
  end

  def type
    [:action]
  end

  def play(game)
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(1)
    game.current_turn.add_actions(1)
    game.current_turn.add_coins(1)
    @log_updater.get_from_card(game.current_player, '+1 action and +$1')
  end

end
