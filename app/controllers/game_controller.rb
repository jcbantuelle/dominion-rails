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
        @game = Game.find_uncached @game.id # Rails caches this even on reload :(
        data = JSON.parse data
        process_message data unless pending_response?(data['action'])
      end
      ActiveRecord::Base.clear_active_connections!
    end
  end

  def chat(data)
    ApplicationController.games[@game.id].each do |player_id, socket|
      socket.send_data chat_json(current_player, data['message'])
    end
  end

  def pending_response?(action)
    action != 'action_response' && action != 'chat' && @game.turn_actions.count > 0
  end

end
