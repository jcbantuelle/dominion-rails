module Woodcutter

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 3
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    game.current_turn.add_coins(2)
    game.current_turn.add_buys(1)
    @log_updater.get_from_card(game.current_player, '+1 buy and +$2')
  end

end
