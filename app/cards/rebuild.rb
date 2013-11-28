class Rebuild < Card

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
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')

    if game.current_player.deck.count > 0 || game.current_player.discard.count > 0
      @play_thread = Thread.new {
        ActiveRecord::Base.connection_pool.with_connection do
          name_card(game)
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, game.current_player.player)
        end
      }
    else
      @log_updater.custom_message(game.current_player, 'no cards to reveal', 'has')
    end
  end

  def name_card(game)
    options = game.card_names
    action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Choose a card to name:', 1, 1, 'name')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def process_action(game, game_player, action)
    if action.action == 'name'
      @named_card = Card.by_name(action.response)
      LogUpdater.new(game).custom_message(game_player, "#{@named_card.card_html}".html_safe, 'name')
      reveal(game, game_player)
      rebuild_trashed_card(game, game_player) unless @trashed_card.nil?
    elsif action.action == 'gain'
      card = GameCard.find(action.response)
      CardGainer.new(game, game_player, card.name).gain_card('discard')
    end
  end

  private

  def reveal(game, game_player)
    @revealed = []
    @trashed_card = nil
    reveal_cards(game, game_player)
    @log_updater.reveal(game_player, @revealed, 'deck')
    discard_revealed(game)
  end

  def rebuild_trashed_card(game, game_player)
    trashed_card_cost = @trashed_card.calculated_cost(game, game.current_turn)
    CardTrasher.new(game_player, [@trashed_card]).trash
    available_cards = game.cards_costing_less_than(trashed_card_cost[:coin]+4, trashed_card_cost[:potion])
    available_cards = available_cards.select(&:victory_card?)
    if available_cards.count == 0
      @log_updater.custom_message(nil, 'But there are no available cards to gain')
    elsif available_cards.count == 1
      CardGainer.new(game, game_player, available_cards.first.name).gain_card('discard')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game_player, available_cards, 'Choose a victory card to gain:', 1, 1, 'gain')
      TurnActionHandler.process_player_response(game, game_player, action, self)
    end
  end

  def process_revealed_card(card)
    if valid_card?(card)
      @trashed_card = card
    else
      card.update_attribute :state, 'revealed'
    end
    valid_card?(card)
  end

  def discard_revealed(game)
    revealed_cards = game.current_player.player_cards.revealed
    CardDiscarder.new(game.current_player, revealed_cards).discard
  end

  def reveal_finished?(game, player)
    @trashed_card.present? || player.discard.count == 0
  end

  def valid_card?(card)
    card.victory? && card.name != @named_card.name
  end

end
