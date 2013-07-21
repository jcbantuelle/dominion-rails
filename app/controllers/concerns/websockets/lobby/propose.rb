module Websockets::Lobby::Propose

  def propose_game(data)
    player_ids = data['player_ids'] << current_player.id
    in_game_players = Player.where(id: player_ids).in_game

    if too_many_players?(player_ids)
      send_player_count_error
    elsif player_already_in_game?(in_game_players)
      refresh_lobby
      send_player_in_game_error(in_game_players)
    else
      game_creator = GameCreator.new(player_ids, current_player.id)
      game = game_creator.create
      refresh_lobby
      send_game_proposal(game)
    end
  end

  def send_game_proposal(game)
    game_players = game.players

    game_players.each do |player|
      ApplicationController.lobby[player.id].send_data game_proposal_json(game, player) if ApplicationController.lobby[player.id]
    end

    set_timeout(game)
  end

  def send_player_in_game_error(in_game_players)
    ApplicationController.lobby[current_player.id].send_data player_in_game_json(in_game_players)
  end

  def send_timeout(game)
    game_players = game.players.to_a
    timeout_players = game.timed_out_players.to_a
    game.destroy

    game_players.each do |player|
      ApplicationController.lobby[player.id].send_data timeout_json(timeout_players) if ApplicationController.lobby[player.id]
    end
    refresh_lobby
  end

  def too_many_players?(players)
    players.length > 4
  end

  def player_already_in_game?(players)
    players.length > 0
  end

  def set_timeout(game)
    Thread.new {
      sleep(30)
      send_timeout(game) if Game.exists?(game.id) && !game.reload.accepted?
      ActiveRecord::Base.clear_active_connections!
    }
  end

end
