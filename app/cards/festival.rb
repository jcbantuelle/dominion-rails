module Festival

  def starting_count(game)
    10
  end

  def cost
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play(game)
    game.current_turn.add_coins(2)
    game.current_turn.add_buys(1)
    game.current_turn.add_actions(2)
    @log_updater.get_from_card(game.current_player, '+2 actions, +1 buy, and +$2')
  end

end
