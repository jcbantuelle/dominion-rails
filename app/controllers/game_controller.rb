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
      data = JSON.parse data
      # if data['action'] == 'propose'
      #   propose_game(data)
      # elsif data['action'] == 'accept'
      #   accept_game(data)
      # elsif data['action'] == 'decline'
      #   decline_game(data)
      # end
    end
  end

end
