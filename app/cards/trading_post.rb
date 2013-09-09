module TradingPost

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    @play_thread = Thread.new {
      hand = game.current_player.hand
      if hand.count == 0
        @log_updater.custom_message(game.current_player, 'nothing to trash', 'have')
      elsif hand.count == 1
        CardTrasher.new(game.current_player, hand).trash('hand')
      else
        action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, hand, 'Choose 2 cards to trash:', 2, 2)
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
      ActiveRecord::Base.clear_active_connections!
    }
  end

  def process_action(game, game_player, action)
    trashed_cards = PlayerCard.where(id: action.response.split)
    CardTrasher.new(game_player, trashed_cards).trash('hand')
    give_card_to_player(game, game_player, 'silver', 'hand')
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

end
