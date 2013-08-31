module Chapel

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 2
    }
  end

  def type
    [:action]
  end

  def play(game)
    action = TurnAction.create game: game, game_player: game.current_player
    action.update sent_json: choose_cards_json(action, game.current_player.hand, 4, 'Choose up to 4 cards to trash:')

    WebsocketDataSender.send_game_data(game.current_player.player, game, action.sent_json)

    Thread.new {
      while !action.finished? do
        sleep(1)
        action.reload
      end
      trashed_cards = PlayerCard.where(id: action.response.split)
      CardTrasher.new(trashed_cards).trash('hand')
      action.destroy

      hand_json = update_hand_json(game, game.current_player.player)
      WebsocketDataSender.send_game_data(game.current_player.player, game, hand_json)
      ActiveRecord::Base.clear_active_connections!
    }
  end
end
