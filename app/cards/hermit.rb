module Hermit

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 3
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        trash_card(game)
        gain_card(game)
        ActiveRecord::Base.connection.clear_query_cache
        TurnActionHandler.refresh_game_area(game, game.current_player.player)
      end
    }
  end

  def trash_card(game)
    discard = game.current_player.discard
    hand = game.current_player.hand
    available_cards = (hand + discard).reject(&:treasure?)
    LogUpdater.new(game).look(game.current_player, discard, 'discard')
    if available_cards.count == 0
      @log_updater.custom_message(nil, 'But there are no cards to trash')
    elsif available_cards.count == 1
      CardTrasher.new(game.current_player, available_cards).trash()
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, available_cards, 'Choose a card to trash:', 1, 0, 'trash')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def gain_card(game)
    available_cards = game.cards_costing_less_than(4)
    if available_cards.count == 0
      @log_updater.custom_message(nil, 'But there are no available cards to gain')
    elsif available_cards.count == 1
      CardGainer.new(game, game.current_player, available_cards.first.name).gain_card('discard')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, available_cards, 'Choose a card to gain:', 1, 1)
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'trash'
      if action.response.present?
        card = PlayerCard.find action.response
        CardTrasher.new(game.current_player, [card]).trash()
      end
    elsif action.action == 'gain'
      card = GameCard.find(action.response)
      CardGainer.new(game, game_player, card.name).gain_card('discard')
    end
  end

  def discard_reaction(game, game_player)
    if game.current_turn.bought_cards == 0
      hermit = game_player.find_card_in_play('hermit')
      CardTrasher.new(game_player, [hermit]).trash('play')
      give_card_to_player(game, game.current_player, 'madman', 'discard')
      ActiveRecord::Base.connection.clear_query_cache
      TurnActionHandler.refresh_game_area(game, game_player.player)
    end
  end

end
