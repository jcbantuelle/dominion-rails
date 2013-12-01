class Transmute < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 0,
      potion: 1
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        @trashed_card = nil
        trash_card(game)
        gain_card(game) unless @trashed_card.nil?
      end
    }
  end

  def trash_card(game)
    hand = game.current_player.hand
    if hand.count == 0
      LogUpdater.new(game).custom_message(nil, 'But there are no cards to trash')
    elsif hand.count == 1
      @trashed_card = hand.first
      CardTrasher.new(game.current_player, hand).trash('hand')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, hand, 'Choose a card to trash:', 1, 1, 'trash')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def gain_card(game)
    if @trashed_card.action?
      give_card_to_player(game, game.current_player, 'duchy', 'discard')
    end
    if @trashed_card.treasure?
      give_card_to_player(game, game.current_player, 'transmute', 'discard')
    end
    if @trashed_card.victory?
      give_card_to_player(game, game.current_player, 'gold', 'discard')
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'trash'
      @trashed_card = PlayerCard.find action.response
      CardTrasher.new(game.current_player, [@trashed_card]).trash('hand')
    end
  end
end
