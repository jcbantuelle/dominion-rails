module Menagerie

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
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')

    reveal_hand(game)
  end

  private

  def reveal_hand(game)
    hand = game.current_player.player_cards.hand
    @log_updater.reveal(game.current_player, hand, 'hand')
    draw_count = hand.map(&:name).uniq.count == hand.count ? 3 : 1
    card_drawer = CardDrawer.new(game.current_player)
    card_drawer.draw(draw_count)
  end

end
