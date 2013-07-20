class GameController < ApplicationController
  include Tubesock::Hijack, Websockets::Game::Refresh

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
        unless data == 'tubesock-ping'
          data = JSON.parse data
        end
      end
      ActiveRecord::Base.clear_active_connections!
    end
  end

end