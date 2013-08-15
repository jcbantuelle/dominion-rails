module LobbyManagement

  include Json::Lobby

  def refresh_lobby
    flush_offline_players
    flush_in_game_players
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
    ApplicationController.lobby.select! { |player_id, socket| online_lobby_player_ids.include? player_id }
  end

  def flush_in_game_players
    game_players = Player.in_game.select{ |player| player.game.accepted? }.collect(&:id)
    ApplicationController.lobby.reject!{ |player_id, socket| game_players.include? player_id }
  end

  def clear_finished_games
    Player.all.each do |player|
      unless player.game.nil?
        player.update_attribute(:current_game, nil) if player.game.finished?
      end
    end
  end

  def update_lobby
    ApplicationController.lobby.each_pair do |player_id, socket|
      lobby_players = players_without_self(player_id)
      socket.send_data refresh_lobby_json(lobby_players) unless lobby_players.blank?
    end
  end

  def online_lobby_players
    Player.connection.clear_query_cache
    Player.online.in_lobby
  end

  def players_without_self(player_id)
    online_lobby_players.reject{ |p| p.id == player_id }
  end

  def update_lobby_status(in_lobby)
    current_player.update_attribute(:lobby, in_lobby) if current_player
  end

end
