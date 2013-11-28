class JackOfAllTrade < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    give_card_to_player(game, game.current_player, 'silver', 'discard')
    reveal(game)

    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        keep_or_discard(game) if @revealed.count > 0
        draw_to_five(game)
        ActiveRecord::Base.connection.clear_query_cache
        TurnActionHandler.refresh_game_area(game, game.current_player.player)
        trash_card(game)
      end
    }
  end

  def keep_or_discard(game)
    options = [
      { text: 'Discard', value: 'discard' },
      { text: 'Replace', value: 'replace' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, "Discard or Replace on Deck?".html_safe, 1, 1, 'choose')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def process_action(game, game_player, action)
    if action.action == 'choose'
      if action.response == 'discard'
        CardDiscarder.new(game_player, @revealed).discard
      elsif action.response == 'replace'
        put_card_on_deck(game, game_player, @revealed.first, false)
      end
    elsif action.action == 'trash'
      card = PlayerCard.find action.response
      CardTrasher.new(game.current_player, [card]).trash('hand')
    end
  end

  def trash_card(game)
    hand = game.current_player.hand.reject(&:treasure?)
    if hand.count == 0
      @log_updater.custom_message(nil, 'There are no cards to trash')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, hand, 'You may choose a card to trash:', 1, 0, 'trash')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def draw_to_five(game)
    cards_to_draw = 5 - game.current_player.hand.count
    CardDrawer.new(game.current_player).draw(cards_to_draw) if cards_to_draw > 0
  end

  def reveal(game)
    @revealed = []
    reveal_cards(game, game.current_player)
    @log_updater.look(game.current_player, @revealed, 'deck')
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 1
  end

  def discard_revealed(game)
    game.current_player.discard_revealed
  end

  def reveal_finished?(game, player)
    @revealed.count == 1 || game.current_player.discard.count == 0
  end
end
