class Stable < Card

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
        discard_treasure(game)
      end
    }
  end

  def discard_treasure(game)
    treasures = game.current_player.hand.select(&:treasure?)
    if treasures.count == 0
      @log_updater.custom_message(nil, 'But does not discard a treasure')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, treasures, 'You may discard a treasure:', 1, 0, 'discard')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'discard'
      if action.response.empty?
        @log_updater.custom_message(nil, 'But does not discard a treasure')
      else
        treasure = PlayerCard.find action.response
        CardDiscarder.new(game_player, [treasure]).discard('hand')
        CardDrawer.new(game.current_player).draw(3)
        game.current_turn.add_actions(1)
        LogUpdater.new(game).get_from_card(game.current_player, '+1 action')
      end
    end
  end
end
