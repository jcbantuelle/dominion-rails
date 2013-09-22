module Count

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
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        first_choice(game)
        game.reload
        TurnActionHandler.refresh_game_area(game, game.current_player.player)
        second_choice(game)
      end
      ActiveRecord::Base.connection.clear_query_cache
      TurnActionHandler.refresh_game_area(game, game.current_player.player)
    }
  end

  def first_choice(game)
    options = [
      { text: 'Discard 2 cards', value: 'discard' },
      { text: 'Put card on deck', value: 'deck' },
      { text: 'Gain a copper', value: 'copper' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Choose one:', 1, 1, 'first')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def second_choice(game)
    options = [
      { text: '+$3', value: 'coin' },
      { text: 'Trash your hand', value: 'trash' },
      { text: 'Gain a duchy', value: 'duchy' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Choose one:', 1, 1, 'second')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def process_action(game, game_player, action)
    if action.action == 'first'
      process_first_choice(game, game_player, action)
    elsif action.action == 'second'
      process_second_choice(game, game_player, action)
    elsif action.action == 'discard'
      discarded_cards = PlayerCard.where(id: action.response.split)
      discarded_cards.update_all state: 'discard'
      LogUpdater.new(game).discard(game_player, discarded_cards, 'hand')
    elsif action.action == 'deck'
      returned_card = PlayerCard.find action.response
      put_card_on_deck(game, game_player, returned_card)
    end
  end

  def process_first_choice(game, game_player, action)
    case action.response
    when 'discard'
      hand = game_player.hand
      if hand.count <= 2
        LogUpdater.new(game).discard(game_player, hand, 'hand')
      else
        action = TurnActionHandler.send_choose_cards_prompt(game, game_player, hand, "Choose 2 cards to discard:", 2, 2, 'discard')
        TurnActionHandler.process_player_response(game, game_player, action, self)
      end
    when 'deck'
      action = TurnActionHandler.send_choose_cards_prompt(game, game_player, game_player.hand, 'Choose a card to return to deck:', 1, 1, 'deck')
      TurnActionHandler.process_player_response(game, game_player, action, self)
    when 'copper'
      give_card_to_player(game, game_player, 'copper', 'discard')
    end
  end

  def process_second_choice(game, game_player, action)
    case action.response
    when 'coin'
      game.current_turn.add_coins(3)
      LogUpdater.new(game).get_from_card(game_player, '+$3')
    when 'trash'
      CardTrasher.new(game_player, game_player.hand).trash('hand')
    when 'duchy'
      give_card_to_player(game, game_player, 'duchy', 'discard')
    end
  end

end
