class Storeroom < Card

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
    game.current_turn.add_buys(1)
    @log_updater.get_from_card(game.current_player, '+1 buy')

    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        discard_for_cards(game)
        discard_for_coins(game)
      end
    }
  end

  def process_action(game, game_player, action)
    discarded_cards = PlayerCard.where(id: action.response.split)
    card_count = discarded_cards.count

    CardDiscarder.new(game_player, discarded_cards).discard('hand')
    if action.action == 'card'
      CardDrawer.new(game_player).draw(card_count) unless card_count == 0
    elsif action.action == 'coin'
      game.current_turn.add_coins(card_count)
      LogUpdater.new(game).get_from_card(game_player, "+$#{card_count}")
    end
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

  private

  def discard_for_cards(game)
    action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, game.current_player.hand, 'Choose any number of cards to discard:', 0, 0, 'card')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def discard_for_coins(game)
    action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, game.current_player.hand, 'Choose any number of cards to discard:', 0, 0, 'coin')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

end
