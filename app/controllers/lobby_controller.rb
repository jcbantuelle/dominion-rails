class LobbyController < ApplicationController
  include Tubesock::Hijack

  before_filter :authenticate_player!
  @@lobby = {}

  def update
    set_lobby
    hijack do |tubesock|
      @@lobby[current_player.id] = tubesock
      tubesock.onopen do
        refresh_lobby
      end
    end
  end

  private

  def refresh_lobby
    players = Player.online.in_lobby
    player_ids = players.collect(&:id)
    @@lobby.select! { |id, socket| player_ids.include? id }
    @@lobby.each_pair do |player_id, socket|
      lobby_players = players.reject{ |p| p.id == player_id }
      socket.send_data({action: 'refresh', players: lobby_players}.to_json) unless lobby_players.blank?
    end
  end

end
