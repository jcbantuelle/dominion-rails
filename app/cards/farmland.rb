class Farmland < Card

  def starting_count(game)
    victory_card_count(game)
  end

  def cost(game, turn)
    {
      coin: 6
    }
  end

  def type
    [:victory]
  end

  def value(deck)
    2
  end

  def results(player)
    card_html
  end

  def gain_event(game, player, event)
    if event == 'buy'
      trash_card(game)
      gain_card(game) unless @trashed_card_cost.nil?
    end
  end

  def trash_card(game)
    hand = game.current_player.hand
    if hand.count == 0
      LogUpdater.new(game).custom_message(nil, 'But there are no cards to trash')
    elsif hand.count == 1
      @trashed_card_cost = hand.first.calculated_cost(game, game.current_turn)
      CardTrasher.new(game.current_player, hand).trash('hand')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, hand, 'Choose a card to trash:', 1, 1, 'trash')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def gain_card(game)
    @trashed_card_cost[:coin] += 2
    available_cards = game.cards_equal_to(@trashed_card_cost)
    if available_cards.count == 0
      LogUpdater.new(game).custom_message(nil, 'But there are no available cards to gain')
    elsif available_cards.count == 1
      CardGainer.new(game, game_player, available_cards.first.name).gain_card('discard')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, available_cards, 'Choose a card to gain:', 1, 1, 'gain')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'trash'
      card = PlayerCard.find action.response
      @trashed_card_cost = card.calculated_cost(game, game.current_turn)
      CardTrasher.new(game.current_player, [card]).trash('hand')
    else
      card = GameCard.find(action.response)
      CardGainer.new(game, game_player, card.name).gain_card('discard')
    end
  end
end
