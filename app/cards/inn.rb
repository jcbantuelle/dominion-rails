class Inn < Card

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
    CardDrawer.new(game.current_player).draw(2)
    game.current_turn.add_actions(2)
    @log_updater.get_from_card(game.current_player, '+2 actions')
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        discard_cards(game)
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'discard'
      discarded_cards = PlayerCard.where(id: action.response.split)
      CardDiscarder.new(game_player, discarded_cards).discard('hand')
    elsif action.action == 'gain'
      unless action.response.empty?
        shuffled_cards = PlayerCard.where(id: action.response)
        shuffled_cards.update_all(state: 'deck')
        ActiveRecord::Base.connection.clear_query_cache
        game_player.shuffle_deck
      end
    end
  end

  def gain_event(game, player, event)
    action_cards = player.discard.select(&:action?)
    if action_cards.empty?
      LogUpdater.new(game).custom_message(nil, 'But there are no action cards in discard')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, player, action_cards, 'Choose any number of action cards to shuffle into your deck:', 0, 0, 'gain')
      TurnActionHandler.process_player_response(game, player, action, self)
    end
  end

  private

  def discard_cards(game)
    hand = game.current_player.hand
    if hand.count < 2
      CardDiscarder.new(game_player, hand).discard('hand')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, hand, 'Choose two cards to discard:', 2, 2, 'discard')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

end
