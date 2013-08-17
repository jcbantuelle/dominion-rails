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

  def sorted_hand(player)
    grouped_cards = player.hand.group_by { |card| card.name }
    grouped_cards.map{ |name,cards|
      {
        name: name,
        count: cards.count,
        card_id: cards.first.card_id
      }
    }
  end

end
