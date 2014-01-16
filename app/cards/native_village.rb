class NativeVillage < Card

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
    game.current_turn.add_actions(2)
    @log_updater.get_from_card(game.current_player, '+2 actions')
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        options = [
          { text: 'Set aside top card', value: 'set_aside' },
          { text: 'Return cards to hand', value: 'draw' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Choose one:', 1, 1)
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
    }
  end

  def process_action(game, game_player, action)
    if action.response == 'set_aside'
      top_card = game_player.deck.first
      top_card.update_attribute :state, 'native_village'
      LogUpdater.new(game).set_aside(game_player, [top_card])
    elsif action.response == 'draw'
      native_village = game.current_player.native_village.to_a
      unless native_village.empty?
        game.current_player.native_village.update_all(state: 'hand')
        LogUpdater.new(game).return_to_hand(game.current_player, native_village)
      end
    end
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

end
