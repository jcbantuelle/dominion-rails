class LobbyController < ApplicationController
  include Tubesock::Hijack

  skip_before_filter :unset_lobby_status
  before_filter :authenticate_player!

  def update
    begin
      set_lobby_status
      hijack do |tubesock|
        @@lobby[current_player.id] = tubesock
        tubesock.onopen do
          refresh_lobby
        end
        tubesock.onmessage do |data|
          unless data == 'tubesock-ping'
            data = JSON.parse data
            if data['action'] == 'propose'
              propose_game(data)
            elsif data['action'] == 'accept'
              accept_game(data)
            elsif data['action'] == 'decline'
              decline_game(data)
            end
          end
        end
      end
    rescue => error
      send_server_error(@@lobby[current_player.id], error)
    end
  end

  private

  def propose_game(data)
    data['player_ids'] << current_player.id
    in_game_players = Player.where(id: data['player_ids']).in_game
    if data['player_ids'].length > 4
      send_player_count_error
    elsif in_game_players.length > 0
      refresh_lobby
      send_player_in_game_error(in_game_players)
    else
      game = Game.generate(data['player_ids'])
      refresh_lobby
      send_game_proposal(game)
    end
  end

  def send_game_proposal(game)
    game_players = game.players

    proposed_cards = []
    game.kingdom_cards.each do |card|
      proposed_cards << {name: card.name.titleize, type: card.type.map(&:to_s).join(' ')}
    end

    game_players.each do |player|
      @@lobby[player.id].send_data({
        action: 'propose',
        players: game_players,
        cards: proposed_cards,
        proposer: current_player,
        is_proposer: current_player.id == player.id,
        game_id: game.id
      }.to_json) if @@lobby[player.id]
    end

    Thread.new {
      sleep(30)
      send_timeout(game) if Game.exists?(game.id) && !game.accepted?
    }
  end

  def accept_game(data)
    game = Game.find data['game_id']
    game_players = game.players

    game_players.each do |player|
      @@lobby[player.id].send_data({
        action: 'accept',
        player: current_player
      }.to_json) if @@lobby[player.id]
    end
  end

  def decline_game(data)
    if Game.exists? data['game_id']
      game = Game.find data['game_id']
      game_players = game.players
      game.destroy

      game_players.each do |player|
        player.update_attribute(:current_game, nil)
        @@lobby[player.id].send_data({
          action: 'decline',
          decliner: current_player,
          is_decliner: current_player.id == player.id
        }.to_json) if @@lobby[player.id]
      end
      refresh_lobby
    end
  end

  def send_timeout(game)
    game_players = game.players
    timeout_players = game.timed_out_players
    game.destroy

    game_players.each do |player|
      player.update_attribute(:current_game, nil)
      @@lobby[player.id].send_data({
        action: 'timeout',
        players: timeout_players
      }.to_json) if @@lobby[player.id]
    end
    refresh_lobby
  end

  def send_player_count_error
    @@lobby[current_player.id].send_data({
      action: 'player_count_error'
    }.to_json)
  end

  def send_player_in_game_error(in_game_players)
    @@lobby[current_player.id].send_data({
      action: 'player_in_game_error',
      players: in_game_players
    }.to_json)
  end

end
