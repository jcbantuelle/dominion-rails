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

  def play(game, clone=false)
    @play_thread = Thread.new {
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, game.current_player.hand, 'Choose up to 4 cards to trash:', 4)
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
      ActiveRecord::Base.clear_active_connections!
    }
  end

  def process_action(game, game_player, action)
    trashed_cards = PlayerCard.where(id: action.response.split)
    CardTrasher.new(game_player, trashed_cards).trash('hand')
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

end
