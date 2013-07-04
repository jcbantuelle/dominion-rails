class LobbyController < ApplicationController
  include Tubesock::Hijack

  before_filter :authenticate_player!

  def update
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
          end
        end
      end
    end
  end

  private

  def propose_game(data)
    data['player_ids'] << current_player.id
    game = Game.create
    game.add_players data['player_ids']
    game.generate_board
    send_game_proposal(game)
  end

  def send_game_proposal(game)
    game_players = game.players
    game_player_ids = game_players.collect(&:id)

    proposed_cards = []
    game.kingdom_cards.each do |card|
      proposed_cards << {name: card.name.titleize, type: card.type.map(&:to_s).join(' ')}
    end

    @@lobby.each_pair do |player_id, socket|
      socket.send_data({
        action: 'propose',
        players: game_players,
        cards: proposed_cards,
        proposer: current_player,
        is_proposer: current_player.id == player_id
      }.to_json) if game_player_ids.include?(player_id)
    end
  end

end
