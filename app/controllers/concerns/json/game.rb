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

  def choose_cards_json(game, action, cards, maximum, minimum, text)
    turn = game.current_turn
    {
      cards: cards.map{ |card| card.json(game, turn) },
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

  def choose_card_order_json(game, action, cards, text)
    turn = game.current_turn
    {
      cards: cards.map{ |card| card.json(game, turn) },
      action: 'order_cards',
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
      amount_of_coin_in_hand: game_player.amount_of_coin_in_hand,
      my_turn: same_player?(game.current_player.player, player)
    }
  end

  def card_area(game)
    cards = game.game_cards
    turn = game.current_turn

    kingdom_cards = sort_cards(game, turn, cards.select(&:kingdom?)).collect{ |card| card.json(game, turn) }

    victory_cards = cards.select(&:victory?)
    treasure_cards = cards.select(&:treasure?)
    miscellaneous_cards = cards.select{ |card| %w(curse ruins madman mercenary).include?(card.card.name) }

    common_cards = sort_cards(game, turn, victory_cards) + sort_cards(game, turn, treasure_cards) + sort_cards(game, turn, miscellaneous_cards)
    common_cards = common_cards.collect{ |card| card.json(game, turn) }

    {
      kingdom_cards: kingdom_cards,
      common_cards: common_cards
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
