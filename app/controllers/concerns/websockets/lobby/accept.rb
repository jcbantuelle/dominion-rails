module Websockets::Lobby::Accept

  def accept_game(data)
    game = Game.find data['game_id']
    game.accept_player(current_player.id)

    if game.accepted?
      move_players_to_game(game)
      send_accepted_game(game)
    else
      send_accept_received
    end
  end

  def send_accepted_game(game)
    game.players.each do |player|
      ApplicationController.lobby[player.id].send_data({
        action: 'accepted_game',
        game_id: game.id
      }.to_json) if ApplicationController.lobby[player.id]
    end
  end

  def send_accept_received
    ApplicationController.lobby[current_player.id].send_data({
      action: 'accept_received'
    }.to_json) if ApplicationController.lobby[current_player.id]
  end

  def send_player_count_error
    ApplicationController.lobby[current_player.id].send_data({
      action: 'player_count_error'
    }.to_json)
  end

  def move_players_to_game(game)
    game_players = game.players.collect(&:id)
    ApplicationController.games[game.id] = ApplicationController.lobby.select{ |player_id, socket| game_players.include? player_id }
  end

end
