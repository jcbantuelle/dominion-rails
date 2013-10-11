module Oasi

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 3
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(1)
    game.current_turn.add_actions(1)
    game.current_turn.add_coins(1)
    @log_updater.get_from_card(game.current_player, '+1 action and +$1')
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game.current_player.player)
    unless game.current_player.hand.empty?
      @play_thread = Thread.new {
        ActiveRecord::Base.connection_pool.with_connection do
          action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, game.current_player.hand, 'Choose a card to discard:', 1, 1)
          TurnActionHandler.process_player_response(game, game.current_player, action, self)
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, game.current_player.player)
        end
      }
    end
  end

  def process_action(game, game_player, action)
    discarded_card = PlayerCard.find action.response
    CardDiscarder.new(game_player, [discarded_card]).discard('hand')
  end

end
