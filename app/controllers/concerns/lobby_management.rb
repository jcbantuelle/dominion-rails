module LobbyManagement

  @@lobby = {}

  def refresh_lobby
    flush_offline_players
    update_lobby
  end

  def set_lobby_status
    update_lobby_status true
  end

  def unset_lobby_status
    update_lobby_status false
  end

  private

  def flush_offline_players
    online_lobby_player_ids = online_lobby_players.collect(&:id)
    @@lobby.select! { |player_id, socket| online_lobby_player_ids.include? player_id }
  end

  def update_lobby
    @@lobby.each_pair do |player_id, socket|
      lobby_players = players_without_self(player_id)
      socket.send_data({ action: 'refresh', players: lobby_players }.to_json) unless lobby_players.blank?
    end
  end

  def online_lobby_players
    Player.online.in_lobby
  end

  def players_without_self(player_id)
    online_lobby_players.reject{ |p| p.id == player_id }
  end

  def update_lobby_status(in_lobby)
    current_player.update_attribute(:lobby, in_lobby) if current_player
  end

end
