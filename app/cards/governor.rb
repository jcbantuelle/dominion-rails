class Governor < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    game.current_turn.add_actions(1)
    LogUpdater.new(game).get_from_card(game.current_player, '+1 action')

    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        options = [
          { text: '+3 cards', value: 'card' },
          { text: 'Trash a card', value: 'remodel' },
          { text: 'Gain a Gold', value: 'gold' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Choose one:', 1, 1, 'pick')
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'pick'
      if action.response == 'card'
        draw_cards(game, game_player)
      elsif action.response == 'remodel'
        choose_trash_cards(game, game_player)
      elsif action.response == 'gold'
        gain_coin(game, game_player)
      end
    elsif action.action == 'trash'
      trash_card(game, game_player, action)
    elsif action.action == 'gain'
      gain_card(game, game_player, action)
    end
  end

  def choose_trash_cards(game, game_player)
    choose_trash_card(game, game_player, 2)
    other_players = game.turn_ordered_players.reject{ |p| p.id == game_player.id }
    other_players.each do |other_player|
      choose_trash_card(game, other_player, 1)
    end
  end

  def choose_trash_card(game, game_player, amount)
    hand = game_player.hand
    if hand.count == 0
      @log_updater.custom_message(nil, 'But there are no cards to trash')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game_player, hand, "You may choose a card to trash, gaining a card costing exactly #{amount} more:", 1, 0, 'trash')
      TurnActionHandler.process_player_response(game, game_player, action, self)
    end
  end

  def trash_card(game, game_player, action)
    if action.response.empty?
      LogUpdater.new(game).custom_message(game_player, 'not to trash a card', 'choose')
    else
      trashed_card = PlayerCard.find action.response
      CardTrasher.new(game_player, [trashed_card]).trash('hand')
      trashed_card_cost = trashed_card.calculated_cost(game, game.current_turn)
      remodel_amount = game_player == game.current_player ? 2 : 1
      trashed_card_cost[:coin] += remodel_amount
      available_cards = game.cards_equal_to(trashed_card_cost)
      if available_cards.count == 0
        @log_updater.custom_message(nil, 'But there are no available cards to gain')
      elsif available_cards.count == 1
        CardGainer.new(game, game_player, available_cards.first.name).gain_card('discard')
      else
        action = TurnActionHandler.send_choose_cards_prompt(game, game_player, available_cards, 'Choose a card to gain:', 1, 1, 'gain')
        TurnActionHandler.process_player_response(game, game_player, action, self)
      end
    end
  end

  def gain_card(game, game_player, action)
    card = GameCard.find(action.response)
    CardGainer.new(game, game_player, card.name).gain_card('discard')
  end

  def draw_cards(game, game_player)
    CardDrawer.new(game_player).draw(3)
    other_players = game.turn_ordered_players.reject{ |p| p.id == game_player.id }
    other_players.each do |other_player|
      CardDrawer.new(other_player).draw(1)
    end
  end

  def gain_coin(game, game_player)
    CardGainer.new(game, game_player, 'gold').gain_card('discard')
    other_players = game.turn_ordered_players.reject{ |p| p.id == game_player.id }
    other_players.each do |other_player|
      CardGainer.new(game, other_player, 'silver').gain_card('discard')
    end
  end

end
