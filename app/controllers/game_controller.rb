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
        ActiveRecord::Base.connection_pool.with_connection do
          ActiveRecord::Base.connection.clear_query_cache
          @game = Game.find @game.id
          data = JSON.parse data
          process_message data if accepted_message?(data['action'])
        end
      end
      ActiveRecord::Base.clear_active_connections!
    end
  end

  def chat(data)
    ApplicationController.games[@game.id].each do |player_id, socket|
      socket.send_data chat_json(current_player, data['message'])
    end
  end

  def accepted_message?(action)
     allow_response?(action) && no_pending_threads?(action)
   end

  def allow_response?(action)
    @game.turn_actions.count == 0 || action == 'action_response' || action == 'chat'
  end

  def no_pending_threads?(action)
    no_pending_threads = true
    if %w(action buy end_turn).include?(action) && ApplicationController.games[@game.id][:thread].present?
      no_pending_threads = false if ApplicationController.games[@game.id][:thread].alive?
    end
    no_pending_threads
  end

end
