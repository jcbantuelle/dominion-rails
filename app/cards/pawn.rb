class Pawn < Card

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
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        options = [
          { text: '+1 card', value: 'card' },
          { text: '+1 action', value: 'action' },
          { text: '+1 buy', value: 'buy' },
          { text: '+$1', value: 'coin' },
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Choose two:', 2, 2)
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
    }
  end

  def process_action(game, game_player, action)
    choices = []
    action.response.split.each do |choice|
      if choice == 'card'
        CardDrawer.new(game_player).draw(1)
      elsif choice == 'action'
        game.current_turn.add_actions(1)
        choices << '+1 action'
      elsif choice == 'buy'
        game.current_turn.add_buys(1)
        choices << '+1 buy'
      elsif choice == 'coin'
        game.current_turn.add_coins(1)
        choices << '+$1'
      end
    end
    @log_updater.get_from_card(game.current_player, choices.join(' and '))
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

end
