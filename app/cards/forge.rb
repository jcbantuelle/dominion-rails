class Forge < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 7
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, game.current_player.hand, 'Choose any number of cards to trash:', 0, 0, 'trash')
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'trash'
      trashed_cards = PlayerCard.where(id: action.response.split)
      trashed_cost = trashed_cards.map{ |c| c.calculated_cost(game, game.current_turn)[:coin] }.inject(0, :+)
      CardTrasher.new(game_player, trashed_cards).trash('hand')
      ActiveRecord::Base.connection.clear_query_cache
      TurnActionHandler.refresh_game_area(game, game_player.player)
      gain_card(game, game_player, trashed_cost)
    elsif action.action == 'gain'
      card = GameCard.find(action.response)
      CardGainer.new(game, game_player, card.name).gain_card('discard')
    end
  end

  def gain_card(game, game_player, trashed_cost)
    available_cards = game.cards_equal_to({coin: trashed_cost, potion: 0})
    if available_cards.count == 0
      LogUpdater.new(game).custom_message(nil, 'But there are no available cards to gain')
    elsif available_cards.count == 1
      CardGainer.new(game, game_player, available_cards.first.name).gain_card('discard')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game_player, available_cards, 'Choose a card to gain:', 1, 1, 'gain')
      TurnActionHandler.process_player_response(game, game_player, action, self)
    end
  end

end
