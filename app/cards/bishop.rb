class Bishop < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    game.current_player.add_victory_tokens(1)
    game.current_turn.add_coins(1)
    @log_updater.get_from_card(game.current_player, "+$1 and +1 &nabla;".html_safe)

    game.turn_ordered_players.each do |player|
      trash_card(game, player)
    end
  end

  def trash_card(game, game_player)
    hand = game_player.hand
    if hand.count == 0
      @log_updater.custom_message(nil, 'But there are no cards to trash')
    elsif hand.count == 1 && game_player == game.current_player
      card_cost = hand.first.calculated_cost(game, game.current_turn)
      CardTrasher.new(game_player, hand).trash('hand')
      gain_victory_tokens(game, card_cost)
    else
      if game_player == game.current_player
        action = TurnActionHandler.send_choose_cards_prompt(game, game_player, hand, 'Choose a card to trash:', 1, 1, 'trash')
      else
        action = TurnActionHandler.send_choose_cards_prompt(game, game_player, hand, 'You may choose a card to trash:', 1, 0, 'trash')
      end
      TurnActionHandler.process_player_response(game, game_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    unless action.response.empty?
      card = PlayerCard.find action.response
      card_cost = card.calculated_cost(game, game.current_turn)
      CardTrasher.new(game_player, [card]).trash('hand')
      gain_victory_tokens(game, card_cost) if game_player == game.current_player
    end
  end

  def gain_victory_tokens(game, cost)
    gained_tokens = cost[:coin] / 2
    game.current_player.add_victory_tokens(gained_tokens)
    LogUpdater.new(game).get_from_card(game.current_player, "+#{gained_tokens} &nabla;".html_safe)
  end

end
