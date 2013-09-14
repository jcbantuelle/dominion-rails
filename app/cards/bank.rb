module Bank

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 7
    }
  end

  def type
    [:treasure]
  end

  def play(game, clone=false)
    coins = treasures_in_play(game)
    game.current_turn.add_coins(coins)
    @log_updater.get_from_card(game.current_player, "+$#{coins}")
  end

  def treasures_in_play(game)
    game.current_player.in_play.select(&:treasure?).count
  end
end
