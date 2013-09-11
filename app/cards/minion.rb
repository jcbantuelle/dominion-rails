module Minion

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 5
    }
  end

  def type
    [:action, :attack]
  end

  def play(game, clone=false)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        options = [
          { text: '+$2', value: 'coin' },
          { text: 'Discard hand', value: 'discard' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Choose one:', 1, 1)
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
    }
  end

  def process_action(game, game_player, action)
    if action.response == 'coin'
      game.current_turn.add_coins(2)
      @log_updater.get_from_card(game_player, '+$2')
    elsif action.response == 'discard'
      game.current_turn.add_minion
      hand = game_player.hand
      hand.each(&:discard)
      @log_updater.discard(game_player, hand)
      CardDrawer.new(game_player).draw(4)
    end
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

  def attack(game, players)
    if game.current_turn.minions > 0
      game.current_turn.remove_minion
      players.each do |player|
        hand = player.hand
        if hand.count > 4
          hand.each(&:discard)
          @log_updater.discard(player, hand)
          CardDrawer.new(player).draw(4)
        end
      end
    end
  end

end
