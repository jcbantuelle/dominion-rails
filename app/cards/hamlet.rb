class Hamlet < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 2
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(1)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')

    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        if game.current_player.hand.count == 0
          LogUpdater.new(game).custom_message(nil, 'But there are no cards to discard')
        else
          discard_for_action(game)
          if game.current_player.hand.count == 0
            LogUpdater.new(game).custom_message(nil, 'But there are no cards to discard')
          else
            discard_for_buy(game)
          end
        end
      end
    }
  end

  def process_action(game, game_player, action)
    if action.response.empty?
      CardDiscarder.new(game_player, []).discard('hand')
    else
      discarded_card = PlayerCard.find action.response
      CardDiscarder.new(game_player, [discarded_card]).discard('hand')
      if action.action == 'action'
        game.current_turn.add_actions(1)
        LogUpdater.new(game).get_from_card(game.current_player, '+1 action')
      elsif action.action == 'buy'
        game.current_turn.add_buys(1)
        LogUpdater.new(game).get_from_card(game.current_player, '+1 buy')
      end
    end
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

  private

  def discard_for_action(game)
    action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, game.current_player.hand, 'You may choose a card to discard for +1 action:', 1, 0, 'action')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def discard_for_buy(game)
    action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, game.current_player.hand, 'You may choose a card to discard for +1 buy:', 1, 0, 'buy')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

end
