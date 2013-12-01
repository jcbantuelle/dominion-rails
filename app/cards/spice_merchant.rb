class SpiceMerchant < Card

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
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        trash_treasure(game)
      end
    }
  end

  def trash_treasure(game)
    treasures = game.current_player.hand.select(&:treasure?)
    if treasures.count == 0
      @log_updater.custom_message(nil, 'But does not trash a treasures')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, treasures, 'You may trash a treasure:', 1, 0, 'trash')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'trash'
      if action.response.empty?
        @log_updater.custom_message(nil, 'But does not trash a treasure')
      else
        treasure = PlayerCard.find action.response
        CardTrasher.new(game.current_player, [treasure]).trash('hand')
        options = [
          { text: '+2 cards and +1 action', value: 'cards' },
          { text: '+$2 and +1 buy', value: 'coins' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Choose one:', 1, 1, 'pick')
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
    elsif action.action == 'pick'
      if action.response == 'cards'
        game.current_turn.add_actions(1)
        CardDrawer.new(game.current_player).draw(2)
        LogUpdater.new(game).get_from_card(game.current_player, '+1 action')
      elsif action.response == 'coins'
        game.current_turn.add_coins(2)
        game.current_turn.add_buys(1)
        LogUpdater.new(game).get_from_card(game.current_player, '+1 buy and +$2')
      end
    end
  end
end
