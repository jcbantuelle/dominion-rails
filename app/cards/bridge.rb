module Bridge

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game)
    game.current_turn.add_coins(1)
    game.current_turn.add_buys(1)
    game.current_turn.add_global_discount(1)
    @log_updater.get_from_card(game.current_player, '+1 buy and +$1')
  end

end
