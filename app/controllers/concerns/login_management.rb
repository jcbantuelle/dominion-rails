module LoginManagement

  def keep_player_active
    if current_player
      current_player.touch :last_response_at
      current_player.online = true
      current_player.save
    end
  end

  def log_out_inactive_players
    Player.inactive.update_all(online: false)
    refresh_lobby
  end

end

