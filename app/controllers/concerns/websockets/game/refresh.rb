module Websockets::Game::Refresh

  def refresh_game
    send_game_data current_player, @game, refresh_game_json(@game, current_player)
  end

  def refresh_all
    @game.players.each do |player|
      send_game_data player, @game, refresh_game_json(@game, player)
    end
  end
end
