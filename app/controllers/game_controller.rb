class GameController < ApplicationController
  include Tubesock::Hijack, Websockets::Game::Refresh, Websockets::Game::TurnActions, Json::Game

  before_filter :authenticate_player!

  def show
    @game = Game.find(params[:id])
    ApplicationController.games[@game.id] ||= {}
  end

  def update
    @game = Game.find(params[:id])
    hijack do |tubesock|
      ApplicationController.games[@game.id][current_player.id] = tubesock
      tubesock.onopen do
        refresh_game
      end
      tubesock.onmessage do |data|
        @game = Game.find_uncached @game.id # Rails caches this even on .reload :(
        process_message data
      end
      ActiveRecord::Base.clear_active_connections!
    end
  end

  def chat(data)
    ApplicationController.games[@game.id].each do |player_id, socket|
      message = "<strong>#{current_player.username}:</strong> #{data['message']}"
      json = {
        action: 'chat',
        message: message
      }
      socket.send_data json.to_json
    end
  end

end
