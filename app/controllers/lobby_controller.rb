class LobbyController < ApplicationController
  include Tubesock::Hijack, Websockets::Lobby::Propose, Websockets::Lobby::Accept, Websockets::Lobby::Decline, Websockets::JsonFormatter

  skip_before_filter :unset_lobby_status
  before_filter :authenticate_player!

  def index
    @active_game = current_player.game
    redirect_to game_path(@active_game) if @active_game.present? && @active_game.accepted?
  end

  def update
    set_lobby_status
    hijack do |tubesock|
      ApplicationController.lobby[current_player.id] = tubesock
      tubesock.onopen do
        refresh_lobby
      end
      tubesock.onmessage do |data|
        process_message(data)
      end
      ActiveRecord::Base.clear_active_connections!
    end
  end

  def process_message(data)
    unless data == 'tubesock-ping'
      data = JSON.parse data
      if data['action'] == 'propose'
        propose_game(data)
      elsif data['action'] == 'accept'
        accept_game(data)
      elsif data['action'] == 'decline'
        decline_game(data)
      end
    end
  end

end
