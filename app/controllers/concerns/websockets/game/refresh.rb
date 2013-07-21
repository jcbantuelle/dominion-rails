module Websockets::Game::Refresh

  def refresh_game
    @game.players.each do |player|
      send_game_data player, @game, refresh_game_json(@game)
    end
  end

end
