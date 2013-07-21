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
      ApplicationController.lobby[player.id].send_data accepted_json(game) if ApplicationController.lobby[player.id]
    end
  end

  def send_accept_received
    ApplicationController.lobby[current_player.id].send_data accept_received_json if ApplicationController.lobby[current_player.id]
  end

  def send_player_count_error
    ApplicationController.lobby[current_player.id].send_data player_count_error_json
  end

end
