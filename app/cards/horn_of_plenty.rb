class HornOfPlenty < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:treasure]
  end

  def play(game, clone=false)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        gain_card(game)
        trash_card(game) if @gained_victory_card
        ActiveRecord::Base.connection.clear_query_cache
        TurnActionHandler.refresh_game_area(game, game.current_player.player)
      end
    }
  end

  def gain_card(game)
    cards_in_play = game.current_player.in_play.map(&:name).uniq.count
    available_cards = game.cards_costing_less_than(cards_in_play+1)

    if available_cards.count == 0
      @log_updater.custom_message(nil, 'But there are no available cards to gain')
    elsif available_cards.count == 1
      @gained_card = available_cards.first
      @gained_victory_card = @gained_card.victory_card?
      CardGainer.new(game, game_player, @gained_card.name).gain_card('discard')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, available_cards, 'Choose a card to gain:', 1, 1, 'gain')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'gain'
      @gained_card = GameCard.find(action.response)
      @gained_victory_card = @gained_card.victory_card?
      CardGainer.new(game, game_player, @gained_card.name).gain_card('discard')
    end
  end

  def trash_card(game)
    card = game.current_player.find_card_in_play name
    CardTrasher.new(game.current_player, [card]).trash('play')
  end

end
