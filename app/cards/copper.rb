class Copper < Card

  def starting_count(game)
    60
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
    1 + coppersmith(game)
  end

  def play(game, clone=false)
    game.current_turn.add_coins(coin(game))
    coppersmith = coppersmith(game)
    LogUpdater.new(game).get_from_card(game.current_player, "+$#{coppersmith(game)} from Coppersmith") if coppersmith(game) > 0
  end

  def coppersmith(game)
    game.current_turn.coppersmith
  end

end
