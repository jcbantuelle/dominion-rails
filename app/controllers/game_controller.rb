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
        process_message data
      end
      ActiveRecord::Base.clear_active_connections!
    end
  end

  def process_message(data)
    unless data == 'tubesock-ping'
      @game.reload
      data = JSON.parse data
      if data['action'] == 'end_turn'
        end_turn(data)
      elsif data['action'] == 'play_card'
        play_card(data)
      elsif data['action'] == 'buy_card'
        buy_card(data)
      end
    end
  end

end
