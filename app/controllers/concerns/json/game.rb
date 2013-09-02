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

  def update_hand_json(game, player)
    {
      action: 'update_hand'
    }.merge(game_content(game, player)).to_json
  end

  def buy_card_json(game, player)
    {
      action: 'buy_card'
    }.merge(game_content(game, player)).to_json
  end

  def choose_cards_json(action, cards, maximum, minimum, text)
    {
      cards: cards.map(&:json),
      maximum: maximum,
      minimum: minimum,
      action: 'choose_cards',
      action_id: action.id,
      text: text
    }.to_json
  end

  def choose_text_json(action, text_options, maximum, minimum, text)
    {
      text_options: text_options,
      maximum: maximum,
      minimum: minimum,
      action: 'choose_text',
      action_id: action.id,
      text: text
    }.to_json
  end

  private

  def game_content(game, player)
    json = game_area(game, player).merge(card_area(game))
    json.merge!(end_game(game)) if game.finished?
    json
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
    game.ranked_players.map{ |player|
      point_cards = grouped_cards(player.point_cards)
      json = {
        id: player.id,
        username: player.username,
        score: player.score,
        cards: grouped_cards(player.point_cards),
        victory_tokens: player.victory_tokens
      }
      assign_card_html(game, player, json)
    }
  end

  def assign_card_html(game, player, json)
    json[:cards].each_with_index{ |card, index|
      html = Card.find(card[:card_id]).results(player.player_cards)
      json[:cards][index][:html] = html
    }
    json
  end

end
