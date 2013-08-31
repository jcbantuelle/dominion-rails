module Cellar

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 2
    }
  end

  def type
    [:action]
  end

  def play(game)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')

    prompt_player_response(game)
  end

  private

  def prompt_player_response(game)
    action = TurnAction.create game: game, game_player: game.current_player
    action.update sent_json: choose_cards_json(action, game.current_player.hand, 0, 'Choose any number of cards to discard:')

    WebsocketDataSender.send_game_data(game.current_player.player, game, action.sent_json)

    process_player_response(game, action)
  end

  def process_player_response(game, action)
    Thread.new {
      action = wait_for_response(action)
      discard_cards(game, action)
      action.destroy
      update_player_hand(game, game.current_player.player)
      ActiveRecord::Base.clear_active_connections!
    }
  end

  def discard_cards(game, action)
    discarded_cards = PlayerCard.where(id: action.response.split)
    discarded_cards.update_all state: 'discard'
    LogUpdater.new(game).discard(game.current_player, discarded_cards, 'hand')
    draw_cards(game, discarded_cards.count)
  end

  def draw_cards(game, draw_count)
    CardDrawer.new(game.current_player).draw(draw_count) unless draw_count == 0
  end
end
