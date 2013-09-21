module BandOfMisfit

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        card_cost = calculated_cost(game, game.current_turn)
        available_cards = game.cards_costing_less_than(card_cost[:coin], card_cost[:potion]).select(&:action_card?)
        if available_cards.count == 0
          LogUpdater.new(game).custom_message(nil, 'But there is nothing to copy')
        elsif available_cards.count == 1
          mimic_card(game, game.current_player, available_cards.first)
        else
          action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, available_cards, "Choose a card to copy:", 1)
          TurnActionHandler.process_player_response(game, game.current_player, action, self)
        end
        ActiveRecord::Base.connection.clear_query_cache
        TurnActionHandler.refresh_game_area(game, game.current_player.player)
      end
    }
  end

  def process_action(game, game_player, action)
    mimic_card game, game_player, GameCard.find(action.response)
  end

  def mimic_card(game, game_player, card)
    misfits = game_player.find_card_in_play('band_of_misfits')
    unless misfits.nil?
      game.current_turn.update actions: game.current_turn.actions + 1, played_actions: game.current_turn.played_actions - 1
      misfits.update state: 'hand', band_of_misfits: true, card_id: card.card_id
      CardPlayer.new(game, misfits.card_id, false, false, misfits.id).play_card
    end
  end

end
