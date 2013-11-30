class Embassy < Card

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
    CardDrawer.new(game.current_player).draw(5)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        discard_cards(game)
      end
    }
  end

  def process_action(game, game_player, action)
    discarded_cards = PlayerCard.where(id: action.response.split)
    CardDiscarder.new(game_player, discarded_cards).discard('hand')
  end

  def gain_event(game, player, event)
    other_players = game.turn_ordered_players.reject{ |p| p.id == player.id }
    other_players.each do |other_player|
      give_card_to_player(game, other_player, 'silver', 'discard')
    end
  end

  private

  def discard_cards(game)
    hand = game.current_player.hand
    if hand.count < 4
      CardDiscarder.new(game_player, hand).discard('hand')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, hand, 'Choose three cards to discard:', 3, 3, 'discard')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

end
