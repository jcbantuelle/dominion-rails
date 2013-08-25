module Lighthouse

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 2
    }
  end

  def type
    [:action, :duration]
  end

  def play(game)
    game.current_turn.add_actions(1)
    game.current_turn.add_coins(1)
    game.current_turn.add_lighthouse
    @log_updater.get_from_card(game.current_player, '+1 action and +$1')
  end

  def duration(game)
    game.current_turn.add_coins(1)
    @log_updater.get_from_card(game.current_player, "+$1 from #{self.card_html}")
  end

end
