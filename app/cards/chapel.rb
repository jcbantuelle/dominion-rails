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

    process_player_response(game, action)
  end

  private

  def process_player_response(game, action)
    Thread.new {
      action = wait_for_response(action)
      trash_cards(action)
      action.destroy
      update_player_hand(game, game.current_player.player)
      ActiveRecord::Base.clear_active_connections!
    }
  end

  def trash_cards(action)
    trashed_cards = PlayerCard.where(id: action.response.split)
    CardTrasher.new(trashed_cards).trash('hand')
  end

end
