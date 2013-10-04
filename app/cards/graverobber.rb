module Graverobber

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
        options = [
          { text: 'Gain from Trash', value: 'gain' },
          { text: 'Trash an Action', value: 'trash' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Choose one:', 1, 1, 'pick')
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'pick'
      if action.response == 'gain'
        gain_from_trash(game, game_player)
      elsif action.response == 'trash'
        trash_action_card(game, game_player)
      end
    elsif action.action == 'gain_from_trash'
      gain_trash_on_deck(game, game_player, GameTrash.find(action.response))
    elsif action.action == 'trash'
      trash_from_hand(game, game_player, PlayerCard.find(action.response))
    elsif action.action == 'gain'
      card = GameCard.find(action.response)
      CardGainer.new(game, game_player, card.name).gain_card('discard')
    end
  end

  def trash_action_card(game, game_player)
    actions_in_hand = game_player.hand.select(&:action?)
    if actions_in_hand.count == 0
      @log_updater.custom_message(nil, 'But there are no actions to trash')
    elsif actions_in_hand.count == 1
      trash_from_hand(game, game_player, actions_in_hand.first)
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game_player, actions_in_hand, 'Choose a card to trash:', 1, 1, 'trash')
      TurnActionHandler.process_player_response(game, game_player, action, self)
    end
  end

  def gain_card_costing_more(game, game_player, cost)
    available_cards = game.cards_costing_less_than(cost[:coin]+4, cost[:potion])
    if available_cards.count == 0
      @log_updater.custom_message(nil, 'But there are no available cards to gain')
    elsif available_cards.count == 1
      CardGainer.new(game, game_player, available_cards.first.name).gain_card('discard')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game_player, available_cards, 'Choose a card to gain:', 1, 1, 'gain')
      TurnActionHandler.process_player_response(game, game_player, action, self)
    end
  end

  def trash_from_hand(game, game_player, trashed_card)
    trashed_card_cost = trashed_card.calculated_cost(game, game.current_turn)
    CardTrasher.new(game_player, [trashed_card]).trash('hand')
    gain_card_costing_more(game, game_player, trashed_card_cost)
  end

  def gain_from_trash(game, game_player)
    trash = game.trash_cards_costing_between(6, 3)
    if trash.count == 0
      @log_updater.custom_message(nil, 'But there are no cards to gain')
    elsif trash.count == 1
      gain_trash_on_deck(game, game_player, trash.first)
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game_player, trash, 'Choose a card to gain:', 1, 1, 'gain_from_trash')
      TurnActionHandler.process_player_response(game, game_player, action, self)
    end
  end

  def gain_trash_on_deck(game, game_player, trash_card)
    card = PlayerCard.create(game_player: game_player, card: trash_card.card, state: 'discard')
    put_card_on_deck(game, game_player, card)
    trash_card.destroy
  end

end
