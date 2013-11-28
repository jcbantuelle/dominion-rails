class DameMolly < Knight

  def play(game, clone=false)
    game.current_turn.add_actions(2)
    @log_updater.get_from_card(game.current_player, '+2 actions')
  end

  def trash_self(game)
    card_to_trash = game.current_player.find_card_in_play('dame_molly')
    CardTrasher.new(game.current_player, [card_to_trash]).trash unless card_to_trash.nil?
  end

end
