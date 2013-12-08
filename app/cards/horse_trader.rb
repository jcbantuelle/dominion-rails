class HorseTrader < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:action, :reaction]
  end

  def play(game, clone=false)
    game.current_turn.add_coins(3)
    game.current_turn.add_buys(1)
    @log_updater.get_from_card(game.current_player, '+1 buy and +$3')
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        discard_cards(game)
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'discard'
      discarded_cards = PlayerCard.where(id: action.response.split)
      CardDiscarder.new(game_player, discarded_cards).discard('hand')
    elsif action.action == 'reaction'
      if action.response == 'yes'
        @horse_trader.update_attribute :state, 'horse_trader'
        LogUpdater.new(game).custom_message(game_player, "aside #{@horse_trader.card.card_html}".html_safe, 'set')
        ActiveRecord::Base.connection.clear_query_cache
        TurnActionHandler.refresh_game_area(game, game_player.player)
      end
    end
  end

  def discard_cards(game)
    hand = game.current_player.hand
    if hand.count < 3
      CardDiscarder.new(game_player, hand).discard('hand')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, hand, 'Choose two cards to discard:', 2, 2, 'discard')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def reaction(game, game_player, card)
    @horse_trader = card
    @reaction_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        options = [
          { text: 'Yes', value: 'yes' },
          { text: 'No', value: 'no' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game_player, options, "Set aside #{card_html}?".html_safe, 1, 1, 'reaction')
        TurnActionHandler.process_player_response(game, game_player, action, self)
      end
    }
  end

end
