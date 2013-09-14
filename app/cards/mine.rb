module Mine

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
        trash_treasure(game)
        gain_treasure(game) unless @trashed_treasure_cost.nil?
        ActiveRecord::Base.connection.clear_query_cache
        TurnActionHandler.refresh_game_area(game, game.current_player.player)
      end
    }
  end

  def trash_treasure(game)
    treasures = game.current_player.hand.select(&:treasure?)
    if treasures.count == 0
      @log_updater.custom_message(nil, 'But there are no treasures to trash')
    elsif treasures.count == 1
      @trashed_treasure_cost = treasures.first.calculated_cost(game)
      CardTrasher.new(game.current_player, treasures).trash('hand')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, treasures, 'Choose a treasure to trash:', 1, 1, 'trash')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def gain_treasure(game)
    available_cards = game.cards_costing_less_than(@trashed_treasure_cost[:coin]+4, @trashed_treasure_cost[:potion]).select(&:treasure_card?)
    if available_cards.count == 0
      @log_updater.custom_message(nil, 'But there are no available treasures to gain')
    elsif available_cards.count == 1
      CardGainer.new(game, game_player, available_cards.first.name).gain_card('discard')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, available_cards, 'Choose a treasure to gain:', 1, 1, 'gain')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'trash'
      treasure = PlayerCard.find action.response
      @trashed_treasure_cost = treasure.calculated_cost(game)[:coin]
      CardTrasher.new(game.current_player, [treasure]).trash('hand')
    else
      card = GameCard.find(action.response)
      CardGainer.new(game, game_player, card.name).gain_card('discard')
    end
  end
end
