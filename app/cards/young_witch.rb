class YoungWitch < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:action, :attack]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(2)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        discard_cards(game)
      end
    }
  end

  def attack(game, players)
    players.each do |player|
      if player.find_card_in_hand(game.bane_card)
        bane_card = Card.by_name(game.bane_card)
        options = [
          { text: 'Yes', value: 'yes' },
          { text: 'No', value: 'no' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, player, options, "Reveal #{bane_card.card_html}?".html_safe, 1, 1, 'reveal')
        TurnActionHandler.process_player_response(game, player, action, self)
      else
        give_card_to_player(game, player, 'curse', 'discard')
      end
    end
  end

  def discard_cards(game)
    hand = game.current_player.hand
    if hand.count < 3
      CardDiscarder.new(game_player, hand).discard('hand')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, hand, 'Choose two cards to discard:', 2, 2, 'discard')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'discard'
      discarded_cards = PlayerCard.where(id: action.response.split)
      CardDiscarder.new(game_player, discarded_cards).discard('hand')
    elsif action.action == 'reveal'
      if action.response == 'yes'
        bane_card = game_player.find_card_in_hand(game.bane_card)
        LogUpdater.new(game).reveal(game_player, [bane_card], 'hand')
      elsif action.response == 'no'
        give_card_to_player(game, game_player, 'curse', 'discard')
      end
    end
  end
end
