class SecretChamber < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 2
    }
  end

  def type
    [:action, :reaction]
  end

  def play(game, clone=false)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        prompt_player_response(game)
      end
    }
  end

  def process_action(game, game_player, action)
    case action.action
    when 'discard'
      process_discard_action(game, game_player, action)
    when 'reveal'
      process_reveal_action(game, game_player, action)
    when 'reorder'
      process_reorder_action(game, game_player, action)
    when 'replace'
      process_replace_action(game, game_player, action)
    end
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

  def process_discard_action(game, game_player, action)
    discarded_cards = PlayerCard.where(id: action.response.split)
    CardDiscarder.new(game_player, discarded_cards).discard('hand')
    game.current_turn.add_coins(discarded_cards.count)
    LogUpdater.new(game).get_from_card(game_player, "+$#{discarded_cards.count}")
  end

  def process_reveal_action(game, game_player, action)
    if action.response == 'yes'
      LogUpdater.new(game).reveal(game_player, [self], 'hand')
      CardDrawer.new(game_player).draw(2)
      action = TurnActionHandler.send_choose_cards_prompt(game, game_player, game_player.hand, 'Choose 2 cards to put on deck', 2, 2, 'reorder')
      TurnActionHandler.process_player_response(game, game_player, action, self)
    end
  end

  def process_reorder_action(game, game_player, action)
    chosen_cards = PlayerCard.where(id: action.response.split)
    action = TurnActionHandler.send_order_cards_prompt(game, game_player, chosen_cards, 'Choose order to put cards on deck (1st is top of deck)', 'replace')
    TurnActionHandler.process_player_response(game, game_player, action, self)
  end

  def process_replace_action(game, game_player, action)
    action.response.split.reverse.each do |card_id|
      card = PlayerCard.find card_id
      put_card_on_deck(game, game_player, card, false)
    end
  end

  def reaction(game, game_player)
    @reaction_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        options = [
          { text: 'Yes', value: 'yes' },
          { text: 'No', value: 'no' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game_player, options, "Reveal #{card_html}?".html_safe, 1, 1, 'reveal')
        TurnActionHandler.process_player_response(game, game_player, action, self)
      end
    }
  end

  private

  def prompt_player_response(game)
    action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, game.current_player.hand, 'Choose any number of cards to discard:', 0, 0, 'discard')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

end
