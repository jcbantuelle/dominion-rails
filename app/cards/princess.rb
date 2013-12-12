class Princess < Card

  def starting_count(game)
    1
  end

  def cost(game, turn)
    {
      coin: 0
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    game.current_turn.add_buys(1)
    game.current_turn.add_global_discount(2) unless clone
    @log_updater.get_from_card(game.current_player, '+1 buy')
  end

end
