module Websockets::Lobby::Decline

  def decline_game(data)
    if Game.exists? data['game_id']
      game = Game.find data['game_id']
      game_players = game.players.to_a
      game.destroy

      game_players.each do |player|
        send_lobby_data player, decline_game_json(player)
      end
      refresh_lobby
    end
  end

end
