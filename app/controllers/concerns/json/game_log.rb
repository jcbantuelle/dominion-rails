module Json::GameLog

  def end_turn_log(game, player)
    message = '<strong>- '
    message += same_player?(game.current_player.player, player) ? "Your " : "#{game.current_player.username}'s "
    message += "turn #{((game.turn - 1) / game.player_count) + 1}"
    message +=' -</strong>'
  end

end
