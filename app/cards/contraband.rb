class Contraband < Card

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
    game.current_turn.add_coins(3)
    game.current_turn.add_buys(1)
    @log_updater.get_from_card(game.current_player, '+1 buy')

    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        player_to_left = game.player_to_left(game.current_player)
        available_cards = game.game_cards
        action = TurnActionHandler.send_choose_cards_prompt(game, player_to_left, available_cards, 'Choose a card to make contraband:', 1, 1, 'contraband')
        TurnActionHandler.process_player_response(game, player_to_left, action, self)
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'contraband'
      game_card = GameCard.find(action.response)
      game.current_turn.add_contraband(game_card.id)
      LogUpdater.new(game).custom_message(game_player, "#{game_card.card.card_html} as contraband", 'name')
    end
  end

end
