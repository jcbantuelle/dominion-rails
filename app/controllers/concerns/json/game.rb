module Json::Game

  include Json::Helper

  def refresh_game_json(game, player)
    {
      action: 'refresh'
    }.merge(game_content(game, player)).to_json
  end

  def end_turn_json(game, player)
    {
      action: 'end_turn'
    }.merge(game_content(game, player)).to_json
  end

  def end_game_json(game, player)
    {
      action: 'end_game',
    }.merge(game_content(game, player)).to_json
  end

  def play_card_json(game, player)
    {
      action: 'play_card'
    }.merge(game_content(game, player)).to_json
  end

  def buy_card_json(game, player)
    {
      action: 'buy_card'
    }.merge(game_content(game, player)).to_json
  end

  private

  def game_content(game, player)
    game_area(game, player).merge(card_area(game)).merge(end_game(game))
  end

  def game_area(game, player)
    game_player = game.game_player(player.id)
    {
      current_turn: game.current_turn,
      deck_count: game_player.deck.count,
      discard_count: game_player.discard.count,
      hand: grouped_cards(game_player.hand),
      my_turn: same_player?(game.current_player.player, player)
    }
  end

  def card_area(game)
    {
      kingdom_cards: game_cards(game, 'kingdom'),
      common_cards: common_cards(game)
    }
  end

  def end_game(game)
    {
      winner: game.winner,
      players: end_game_players(game)
    }
  end

  def end_game_players(game)
    game.game_players.map{ |player|
      {
        id: player.id,
        username: player.username,
        score: player.score,
        cards: grouped_cards(player.point_cards)
      }
    }
  end

end
