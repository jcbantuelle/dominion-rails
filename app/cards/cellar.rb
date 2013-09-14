module Cellar

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
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')

    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        prompt_player_response(game)
      end
    }
  end

  def process_action(game, game_player, action)
    discarded_cards = PlayerCard.where(id: action.response.split)
    discarded_cards.update_all state: 'discard'
    LogUpdater.new(game).discard(game_player, discarded_cards, 'hand')
    draw_cards(game, discarded_cards.count)
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

  private

  def prompt_player_response(game)
    action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, game.current_player.hand, 'Choose any number of cards to discard:')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def draw_cards(game, draw_count)
    CardDrawer.new(game.current_player).draw(draw_count) unless draw_count == 0
  end
end
