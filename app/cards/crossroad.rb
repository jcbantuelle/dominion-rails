module Crossroad

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 2
    }
  end

  def type
    [:action]
  end

  def play(game)
    game.current_turn.add_crossroad
    reveal_hand(game)

    if game.current_turn.crossroads == 1
      game.current_turn.add_actions(3)
      @log_updater.get_from_card(game.current_player, '+3 actions')
    end
  end

  private

  def reveal_hand(game)
    hand = game.current_player.player_cards.hand
    @log_updater.reveal(game.current_player, hand, 'hand')
    draw_count = hand.select{ |c| c.victory? }.count
    card_drawer = CardDrawer.new(game.current_player)
    card_drawer.draw(draw_count)
  end

end
