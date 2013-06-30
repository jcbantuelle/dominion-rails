class LobbyController < ApplicationController
  include Tubesock::Hijack

  before_filter :authenticate_player!

  def update
    set_lobby_status
    hijack do |tubesock|
      @@lobby[current_player.id] = tubesock
      tubesock.onopen do
        refresh_lobby
      end
      tubesock.onmessage do |data|
        unless data == 'tubesock-ping'
          data = JSON.parse data
          if data['action'] == 'propose'
            propose_game(data)
          end
        end
      end
    end
  end

  private

  def propose_game(data)
    data['player_ids'] << current_player.id
    game = Game.create
    game.add_players data['player_ids']
    game.generate_board
  end

end
