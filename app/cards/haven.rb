class Haven < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 2
    }
  end

  def type
    [:action, :duration]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(1)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        set_aside_card(game)
      end
    }
  end

  def set_aside_card(game)
    hand = game.current_player.hand
    if hand.count == 0
      @log_updater.custom_message(nil, 'But there are no cards to set aside')
    elsif hand.count == 1
      hand.first.update_attribute :state, 'haven'
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, hand, 'Choose a card to set aside:', 1, 1, 'set_aside')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'set_aside'
      card = PlayerCard.find action.response
      card.update_attribute :state, 'haven'
      LogUpdater.new(game).set_aside(game_player, [card])
    end
  end

  def duration(game)
    havens = game.current_player.havens.to_a
    unless havens.empty?
      game.current_player.havens.update_all(state: 'hand')
      LogUpdater.new(game).return_to_hand(game.current_player, havens)
    end
  end

end
