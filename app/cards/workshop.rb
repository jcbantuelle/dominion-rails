module Workshop

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
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        available_cards = game.cards_costing_less_than(5)
        if available_cards.count == 0
          @log_updater.custom_message(nil, 'But there are no available cards to gain')
        else
          action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, available_cards, 'Choose a card to gain:', 1, 1)
          TurnActionHandler.process_player_response(game, game.current_player, action, self)
        end
      end
    }
  end

  def process_action(game, game_player, action)
    card = GameCard.find action.response
    CardGainer.new(game, game_player, card.name).gain_card('discard')
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end
end
