module Websockets::Lobby::Propose

  def propose_game(data)
    data['player_ids'] << current_player.id
    in_game_players = Player.where(id: data['player_ids']).in_game
    if data['player_ids'].length > 4
      send_player_count_error
    elsif in_game_players.length > 0
      refresh_lobby
      send_player_in_game_error(in_game_players)
    else
      game = Game.generate(players: data['player_ids'], proposer: current_player.id)
      refresh_lobby
      send_game_proposal(game)
    end
  end

  def send_game_proposal(game)
    game_players = game.players

    game_players.each do |player|
      ApplicationController.lobby[player.id].send_data({
        action: 'propose',
        players: game_players,
        cards: game.proposed_cards,
        proposer: current_player,
        is_proposer: current_player.id == player.id,
        game_id: game.id
      }.to_json) if ApplicationController.lobby[player.id]
    end

    Thread.new {
      sleep(30)
      send_timeout(game) if Game.exists?(game.id) && !game.accepted?
      ActiveRecord::Base.clear_active_connections!
    }
  end

  def send_player_in_game_error(in_game_players)
    ApplicationController.lobby[current_player.id].send_data({
      action: 'player_in_game_error',
      players: in_game_players
    }.to_json)
  end

  def send_timeout(game)
    game_players = game.players
    timeout_players = game.timed_out_players
    game.destroy

    game_players.each do |player|
      player.update_attribute(:current_game, nil)
      ApplicationController.lobby[player.id].send_data({
        action: 'timeout',
        players: timeout_players
      }.to_json) if ApplicationController.lobby[player.id]
    end
    refresh_lobby
  end

end
