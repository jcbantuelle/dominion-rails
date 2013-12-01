class Mandarin < Card

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
    game.current_turn.add_coins(3)
    @log_updater.get_from_card(game.current_player, '+$3')

    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        replace_card(game)
      end
    }
  end

  def replace_card(game)
    hand = game.current_player.hand
    if hand.count == 0
      @log_updater.custom_message(nil, 'But there are no cards in hand')
    elsif hand.count == 1
      put_card_on_deck game, game.current_player, hand.first, false
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, hand, 'Choose a card to put on deck:', 1, 1, 'deck')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'deck'
      card = PlayerCard.find action.response
      put_card_on_deck game, game_player, card, false
    elsif action.action == 'reorder'
      action.response.split.reverse.each do |card_id|
        card = PlayerCard.find card_id
        put_card_on_deck game, game_player, card
      end
    end
  end

  def gain_event(game, player, event)
    treasures = player.in_play.select(&:treasure?)
    action = TurnActionHandler.send_order_cards_prompt(game, player, treasures, 'Choose order to put cards on deck (1st is top of deck)', 'reorder')
    TurnActionHandler.process_player_response(game, player, action, self)
  end
end
