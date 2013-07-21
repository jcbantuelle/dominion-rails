module Websockets::Game::Refresh

  def refresh_game
    @game.players.each do |player|
      ApplicationController.games[@game.id][player.id].send_data refresh_game_json(@game) if ApplicationController.games[@game.id][player.id]
    end
  end

end
