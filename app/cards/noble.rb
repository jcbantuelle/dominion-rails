class Noble < Card

  def starting_count(game)
    victory_card_count(game)
  end

  def cost(game, turn)
    {
      coin: 6
    }
  end

  def type
    [:action, :victory]
  end

  def value(deck)
    2
  end

  def play(game, clone=false)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        options = [
          { text: '+3 cards', value: 'card' },
          { text: '+2 action', value: 'action' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Choose one:', 1, 1)
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
    }
  end

  def process_action(game, game_player, action)
    if action.response == 'card'
      CardDrawer.new(game.current_player).draw(3)
    elsif action.response == 'action'
      game.current_turn.add_actions(2)
      @log_updater.get_from_card(game.current_player, '+2 actions')
    end
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

  def results(deck)
    card_html
  end

end
