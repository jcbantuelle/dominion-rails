class Mint < Card

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
        reveal_card(game)
      end
    }
  end

  def reveal_card(game)
    treasures = game.current_player.hand.select(&:treasure?)
    if treasures.count == 0
      LogUpdater.new(game).custom_message(nil, 'But does not reveal a treasure')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, treasures, 'You may choose a treasure to reveal:', 1, 0, 'reveal')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'reveal'
      if action.response.empty?
        LogUpdater.new(game).custom_message(nil, 'But does not reveal a treasure')
      else
        revealed_treasure = PlayerCard.find action.response
        CardGainer.new(game, game_player, revealed_treasure.name).gain_card('discard')
      end
    end
  end

  def gain_event(game, player, event)
    if event == 'buy'
      treasures_in_play = player.in_play_without_duration.select(&:treasure?)
      CardTrasher.new(player, treasures_in_play).trash('play')
    end
  end
end
