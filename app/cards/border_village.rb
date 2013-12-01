class BorderVillage < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 6
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(1)
    game.current_turn.add_actions(2)
    @log_updater.get_from_card(game.current_player, '+2 actions')
  end

  def gain_event(game, player, event)
    card_cost = calculated_cost(game, game.current_turn)
    available_cards = game.cards_costing_less_than(card_cost[:coin], card_cost[:potion])

    if available_cards.count == 0
      LogUpdater.new(game).custom_message(nil, "But there are no available cards to gain from #{card_html}".html_safe)
    elsif available_cards.count == 1
      CardGainer.new(game, player, available_cards.first.name).gain_card('discard')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, player, available_cards, "Choose a card to gain from #{card_html}:".html_safe, 1, 1)
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    card = GameCard.find(action.response)
    CardGainer.new(game, game_player, card.name).gain_card('discard')
  end

end
