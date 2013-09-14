module Necropoli

  def cost(game, turn)
    {
      coin: 1
    }
  end

  def type
    [:action, :shelter]
  end

  def play(game, clone=false)
    game.current_turn.add_actions(2)
    @log_updater.get_from_card(game.current_player, '+2 actions')
  end

end
