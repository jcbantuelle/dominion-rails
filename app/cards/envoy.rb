class Envoy < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        reveal(game)
        choose_card(game)
        ActiveRecord::Base.connection.clear_query_cache
        TurnActionHandler.refresh_game_area(game, game.current_player.player)
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'discard'
      discarded_card = PlayerCard.find(action.response)
      CardDiscarder.new(game.current_player, [discarded_card]).discard
      drawn_cards = @revealed.reject{|c| c.id.to_s == action.response }
      drawn_cards.each do |card|
        card.update_attribute :state, 'hand'
      end
      LogUpdater.new(game).put(game_player, drawn_cards, 'hand', false)
    end
  end

  def choose_card(game)
    if @revealed.count == 0
      LogUpdater.new(game).custom_message(nil, 'But there are no cards to discard')
    elsif @revealed.count == 1
      CardDiscarder.new(game.current_player, @revealed).discard
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.player_to_left(game.current_player), @revealed, "Choose one of #{game.current_player.username}'s cards to discard", 1, 1, 'discard')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def reveal(game)
    @revealed = []
    reveal_cards(game, game.current_player)
    @log_updater.reveal(game.current_player, @revealed, 'deck')
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 5
  end

  def reveal_finished?(game, player)
    @revealed.count == 5 || game.current_player.discard.count == 0
  end

end
