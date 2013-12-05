class Apprentice < Card

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
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        @trashed_card_cost = nil
        trash_card(game)
        gain_from_card(game) unless @trashed_card_cost.nil?
      end
    }
  end

  def trash_card(game)
    hand = game.current_player.hand
    if hand.count == 0
      LogUpdater.new(game).custom_message(nil, 'But there are no cards to trash')
    elsif hand.count == 1
      @trashed_card_cost = hand.first.calculated_cost(game, game.current_turn)
      CardTrasher.new(game.current_player, hand).trash('hand')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, hand, 'Choose a card to trash:', 1, 1, 'trash')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def gain_from_card(game)
    cards = @trashed_card_cost[:coin]
    cards += (@trashed_card_cost[:potion] * 2) unless @trashed_card_cost[:potion].nil?
    CardDrawer.new(game.current_player).draw(cards)
  end

  def process_action(game, game_player, action)
    if action.action == 'trash'
      card = PlayerCard.find(action.response)
      @trashed_card_cost = card.calculated_cost(game, game.current_turn)
      CardTrasher.new(game.current_player, [card]).trash('hand')
    end
  end
end
