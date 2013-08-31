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
    action = send_choose_cards_prompt(game, game.current_player, 'Choose up to 4 cards to trash:', 4)
    process_player_response(game, action)
  end

  private

  def process_player_response(game, action)
    Thread.new {
      action = wait_for_response(action)
      trash_cards(game, action)
      action.destroy
      update_player_hand(game, game.current_player.player)
      ActiveRecord::Base.clear_active_connections!
    }
  end

  def trash_cards(game, action)
    trashed_cards = PlayerCard.where(id: action.response.split)
    CardTrasher.new(game.current_player, trashed_cards).trash('hand')
  end

end
