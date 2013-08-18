module Json::Helper

  def is_current_player?(player)
    current_player.id == player.id
  end

  def same_player?(player1, player2)
    player1.id == player2.id
  end

  def common_cards(game)
    game_cards(game, 'victory') + game_cards(game, 'treasure') + [game.curse_card.json(game)]
  end

  def game_cards(game, type)
    sort_cards(game, game.send("#{type}_cards")).collect{ |card| card.json(game) }
  end

  def sort_cards(game, cards)
    cards.sort{ |a, b| b.cost(game)[:coin] <=> a.cost(game)[:coin] }
  end

  def grouped_cards(cards)
    grouped_cards = cards.group_by { |card| card.name }
    grouped_cards.map{ |name, card_group|
      {
        name: name,
        count: card_group.count,
        card_id: card_group.first.card_id,
        type_class: card_group.first.type_class,
        title: name.titleize
      }
    }
  end

end
