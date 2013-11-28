class DeathCart < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:action, :looter]
  end

  def play(game, clone=false)
    @clone = clone
    game.current_turn.add_coins(5)
    @log_updater.get_from_card(game.current_player, '+$5')
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        actions_in_hand = game.current_player.hand.select(&:action?)
        if actions_in_hand.count == 0
          trash_self(game)
        elsif actions_in_hand.count == 1
          CardTrasher.new(game.current_player, actions_in_hand).trash
        else
          action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, actions_in_hand, 'You may choose an action to trash:', 1, 0)
          TurnActionHandler.process_player_response(game, game.current_player, action, self)
        end
      end
    }
  end

  def process_action(game, game_player, action)
    if action.response.empty?
      trash_self(game)
    else
      trashed_card = PlayerCard.find action.response
      CardTrasher.new(game_player, [trashed_card]).trash('hand')
    end
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

  def trash_self(game)
    unless @clone
      death_cart = game.current_player.find_card_in_play('death_cart')
      CardTrasher.new(game.current_player, [death_cart]).trash
    end
  end

  def gain_event(game, player, event)
    2.times do
      CardGainer.new(game, player, 'ruins').gain_card('discard')
    end
  end

end
