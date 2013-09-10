module RuinedVillage

  def cost(game)
    {
      coin: 0
    }
  end

  def type
    [:action, :ruin]
  end

  def play(game, clone=false)
    game.current_turn.add_action(1)
    @log_updater.get_from_card(game.current_player, '+1 action')
  end

end
