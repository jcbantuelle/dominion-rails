module Market

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    market(game)
    game.current_turn.add_coins(1)
    @log_updater.get_from_card(game.current_player, '+1 action, +1 buy, and +$1')
  end

end
