class MarketCard < Card

  def market(game)
    card_drawer = CardDrawer.new(game.current_player)
    card_drawer.draw(1)
    game.current_turn.add_actions(1)
    game.current_turn.add_buys(1)
  end

end
