module Copper

  def starting_count(game)
    60
  end

  def cost(game)
    {
      coin: 0
    }
  end

  def type
    [:treasure]
  end

  def play(game, clone=false)
    coppersmith = game.current_turn.coppersmith
    game.current_turn.add_coins(1 + coppersmith)
    @log_updater.get_from_card(game.current_player, "+$#{coppersmith} from Coppersmith") if coppersmith > 0
  end

end
