class Steward < Card

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
        options = [
          { text: '+2 cards', value: 'card' },
          { text: '+$2', value: 'coin' },
          { text: 'Trash 2 cards', value: 'trash' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Choose one:', 1, 1, 'pick')
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'pick'
      pick_option(game, game_player, action)
    elsif action.action == 'trash'
      trash_cards(game, game_player, action)
    end
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

  def pick_option(game, game_player, action)
    case action.response
    when 'card'
      CardDrawer.new(game_player).draw(2)
    when 'coin'
      game.current_turn.add_coins(2)
      @log_updater.get_from_card(game_player, '+$2')
    when 'trash'
      if game_player.hand.count < 3
        CardTrasher.new(game_player, game_player.hand).trash('hand')
      else
        action = TurnActionHandler.send_choose_cards_prompt(game, game_player, game_player.hand, 'Choose 2 cards to trash:', 2, 2, 'trash')
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
    end
  end

  def trash_cards(game, game_player, action)
    trashed_cards = PlayerCard.where(id: action.response.split)
    CardTrasher.new(game_player, trashed_cards).trash('hand')
  end

end
