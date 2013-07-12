class GameController < ApplicationController
  include Tubesock::Hijack

  before_filter :authenticate_player!

  def show
    @game = Game.find(params[:id])
    remove_players_from_lobby
  end

  def update
    hijack do |tubesock|
      tubesock.onopen do
      end
      tubesock.onmessage do |data|
        unless data == 'tubesock-ping'
          data = JSON.parse data
        end
      end
      ActiveRecord::Base.clear_active_connections!
    end
  end

  def remove_players_from_lobby
    game_players = @game.players.collect(&:id)
    ApplicationController.lobby.reject!{ |player_id, socket| game_players.include? player_id }
  end

end
