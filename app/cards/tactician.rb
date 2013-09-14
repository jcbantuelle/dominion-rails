module Tactician

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action, :duration]
  end

  def play(game, clone=false)
    hand = game.current_player.hand
    if hand.count > 0
      hand.each do |card|
        card.discard
      end
      @log_updater.discard(game.current_player, hand)
      game.current_turn.add_tactician
    end
  end

  def duration(game)
    last_turn = game.current_player.turns[1]
    if last_turn.tacticians > 0
      card_drawer = CardDrawer.new(game.current_player)
      card_drawer.draw_duration(5, self)
      game.current_turn.add_buys(1)
      game.current_turn.add_actions(1)
      @log_updater.get_from_card(game.current_player, "+1 action and +1 buy from #{self.card_html}")
      last_turn.remove_tactician
    end
  end

end
