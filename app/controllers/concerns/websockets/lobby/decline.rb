module Websockets::Lobby::Decline

  def decline_game(data)
    if Game.exists? data['game_id']
      game = Game.find data['game_id']
      game_players = game.players.to_a
      game.destroy

      game_players.each do |player|
        ApplicationController.lobby[player.id].send_data decline_game_json(player) if ApplicationController.lobby[player.id]
      end
      refresh_lobby
    end
  end

end
