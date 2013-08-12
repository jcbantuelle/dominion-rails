module Websockets::Lobby::Accept

  def accept_game(data)
    game = Game.find data['game_id']
    PlayerAccepter.accept(game, current_player)

    if game.accepted?
      send_accepted_game(game)
    else
      send_accept_received
    end
  end

  def send_accepted_game(game)
    game.players.each do |player|
      WebsocketDataSender.send_lobby_data player, accepted_json(game)
    end
  end

  def send_accept_received
    WebsocketDataSender.send_lobby_data current_player, accept_received_json
  end

  def send_player_count_error
    WebsocketDataSender.send_lobby_data current_player, player_count_error_json
  end

end
