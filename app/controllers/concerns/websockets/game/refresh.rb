module Websockets::Game::Refresh

  def refresh_game
    send_game_data current_player, @game, refresh_game_json(@game)
  end

end
