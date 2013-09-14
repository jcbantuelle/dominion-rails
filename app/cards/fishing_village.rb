module FishingVillage

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 3
    }
  end

  def type
    [:action, :duration]
  end

  def play(game, clone=false)
    game.current_turn.add_actions(2)
    game.current_turn.add_coins(1)
    @log_updater.get_from_card(game.current_player, '+2 actions and +$1')
  end

  def duration(game)
    game.current_turn.add_actions(1)
    game.current_turn.add_coins(1)
    @log_updater.get_from_card(game.current_player, "+1 action and +$1 from #{self.card_html}")
  end

end
