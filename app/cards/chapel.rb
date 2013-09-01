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

    Thread.new {
  def play(game, clone=false)
      action = send_choose_cards_prompt(game, game.current_player, game.current_player.hand, 'Choose up to 4 cards to trash:', 4)
      process_player_response(game, game.current_player, action)
      ActiveRecord::Base.clear_active_connections!
    }
  end

  private

  def process_action(game, game_player, action)
    trashed_cards = PlayerCard.where(id: action.response.split)
    CardTrasher.new(game_player, trashed_cards).trash('hand')
    update_player_hand(game, game_player.player)
  end

end
