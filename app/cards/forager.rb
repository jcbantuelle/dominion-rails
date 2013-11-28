class Forager < Card

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
    game.current_turn.add_actions(1)
    game.current_turn.add_buys(1)
    @log_updater.get_from_card(game.current_player, '+1 action and +1 buy')
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        trash_card(game)
        gain_coins(game, game.current_player)
        ActiveRecord::Base.connection.clear_query_cache
        TurnActionHandler.refresh_game_area(game, game.current_player.player)
      end
    }
  end

  def trash_card(game)
    hand = game.current_player.hand
    if hand.count == 0
      @log_updater.custom_message(nil, 'But there are no cards to trash')
    elsif hand.count == 1
      @trashed_card_cost = hand.first.calculated_cost(game, game.current_turn)
      CardTrasher.new(game.current_player, hand).trash('hand')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, hand, 'Choose a card to trash:', 1, 1)
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    card = PlayerCard.find action.response
    CardTrasher.new(game.current_player, [card]).trash('hand')
  end

  def gain_coins(game, game_player)
    trashed_treasures = game.trash_by_type('treasure')
    unique_treasure_count = trashed_treasures.collect(&:name).uniq.count
    game.current_turn.add_coins(unique_treasure_count)
    LogUpdater.new(game).get_from_card(game.current_player, "+$#{unique_treasure_count}")
  end
end
