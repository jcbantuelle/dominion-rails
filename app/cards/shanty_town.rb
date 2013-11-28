class ShantyTown < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 3
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    game.current_turn.add_actions(2)
    reveal_hand(game)
    @log_updater.get_from_card(game.current_player, '+2 actions')
  end

  private

  def reveal_hand(game)
    hand = game.current_player.player_cards.hand
    @log_updater.reveal(game.current_player, hand, 'hand')
    draw_cards(game, hand)
  end

  def draw_cards(game, hand)
    if no_actions?(hand)
      @card_drawer = CardDrawer.new(game.current_player)
      @card_drawer.draw(2)
    end
  end

  def no_actions?(hand)
    hand.select(&:action?).count == 0
  end

end
