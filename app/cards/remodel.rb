module Remodel

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    @play_thread = Thread.new {
      trash_card(game)
      gain_card(game) unless @trashed_card_cost.nil?
      game.reload
      TurnActionHandler.refresh_game_area(game, game.current_player.player)
      ActiveRecord::Base.clear_active_connections!
    }
  end

  def trash_card(game)
    hand = game.current_player.hand
    if hand.count == 0
      @log_updater.custom_message(nil, 'But there are no cards to trash')
    elsif hand.count == 1
      @trashed_card_cost = hand.first.calculated_cost(game)
      CardTrasher.new(game.current_player, hand).trash('hand')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, hand, 'Choose a card to trash:', 1, 1, 'trash')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def gain_card(game)
    available_cards = game.cards_costing_less_than(@trashed_card_cost[:coin]+3, @trashed_card_cost[:potion])
    if available_cards.count == 0
      @log_updater.custom_message(nil, 'But there are no available cards to gain')
    elsif available_cards.count == 1
      CardGainer.new(game, game_player, available_cards.first.id).gain_card('discard')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, available_cards, 'Choose a card to gain:', 1, 1, 'gain')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'trash'
      card = PlayerCard.find action.response
      @trashed_card_cost = card.calculated_cost(game)[:coin]
      CardTrasher.new(game.current_player, [card]).trash('hand')
    else
      CardGainer.new(game, game_player, action.response).gain_card('discard')
    end
  end
end
