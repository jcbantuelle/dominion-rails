module Chancellor

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 3
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
        prompt_player_response(game)
      end
    }
  end

  def prompt_player_response(game)
    options = [
      { text: 'Yes', value: 'yes' },
      { text: 'No', value: 'no' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Put Deck into Discard?', 1, 1)
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def process_action(game, game_player, action)
    if action.response == 'yes'
      game_player.deck.update_all state: 'discard'
      @log_updater.custom_message(game_player, 'deck into discard', 'put')
      ActiveRecord::Base.connection.clear_query_cache
      TurnActionHandler.refresh_game_area(game, game_player.player)
    end
  end
end
