class Counterfeit < Card

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
        game.current_turn.add_coins(1)
        game.current_turn.add_buys(1)
        @log_updater.get_from_card(game.current_player, '+1 buy and +$1')
        prompt_player_response(game)
      end
    }
  end

  def process_action(game, game_player, action)
    unless action.response.empty?
      player_card = PlayerCard.find(action.response)
      play_card_multiple_times(game, game_player, player_card, 2)
      CardTrasher.new(game_player, [player_card]).trash
    end
  end

  private

  def prompt_player_response(game)
    treasures = game.current_player.hand.select(&:treasure?)
    if treasures.count == 0
      @log_updater.custom_message(game.current_player, 'no treasures to play', 'have')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, treasures, 'You may choose a treasure to play twice:', 1)
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

end
