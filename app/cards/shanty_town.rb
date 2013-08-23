module ShantyTown

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 3
    }
  end

  def type
    [:action]
  end

  def play(game)
    game.current_turn.add_actions(2)
    hand = game.current_player.player_cards.hand
    @log_updater.reveal(game.current_player, hand, 'hand')
    if hand.select(&:action?).count == 0
      @card_drawer = CardDrawer.new(game.current_player)
      @card_drawer.draw(2)
    end
    @log_updater.get_from_card(game.current_player, '+2 actions')
  end

end
