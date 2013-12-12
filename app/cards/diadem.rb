class Diadem < Card

  def starting_count(game)
    1
  end

  def cost(game, turn)
    {
      coin: 0
    }
  end

  def type
    [:treasure]
  end

  def coin(game)
    2
  end

  def play(game, clone=false)
    coins_to_gain = coin(game)
    coins_to_gain += game.current_turn.actions
    game.current_turn.add_coins(coins_to_gain)
    @log_updater.get_from_card(game.current_player, "+$#{coins_to_gain}")
  end

end
