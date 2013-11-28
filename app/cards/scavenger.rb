class Scavenger < Card

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
    game.current_turn.add_coins(2)
    @log_updater.get_from_card(game.current_player, '+$2')

    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        put_deck_in_discard(game)
        put_card_on_deck(game)
      end
    }
  end

  def put_deck_in_discard(game)
    options = [
      { text: 'Yes', value: 'yes' },
      { text: 'No', value: 'no' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Put Deck into Discard?', 1, 1, 'discard')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def put_card_on_deck(game)
    if game.current_player.discard.count == 0
      @log_updater.custom_message(nil, 'But there are no cards in the discard')
    elsif game.current_player.discard.count == 1
      game.current_player.put_card_on_deck game.current_player.discard.first
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, game.current_player.discard, 'Choose a card to put on deck:', 1, 1, 'deck')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'discard'
      if action.response == 'yes'
        game_player.deck.update_all state: 'discard'
        @log_updater.custom_message(game_player, 'deck into discard', 'put')
        ActiveRecord::Base.connection.clear_query_cache
        TurnActionHandler.refresh_game_area(game, game_player.player)
      end
    elsif action.action == 'deck'
      card = PlayerCard.find action.response
      game_player.put_card_on_deck card
    end
  end
end
