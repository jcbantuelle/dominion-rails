module ThroneRoom

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    @play_thread = Thread.new {
      prompt_player_response(game)
      ActiveRecord::Base.clear_active_connections!
    }
  end

  def process_action(game, game_player, action)
    play_card_multiple_times(game, PlayerCard.find(action.response), 2)
  end

  private

  def prompt_player_response(game)
    actions = game.current_player.hand.select(&:action?)
    if actions.count == 0
      @log_updater.custom_message(game.current_player, 'no actions to play', 'have')
    elsif actions.count == 1
      play_card_multiple_times(game, actions.first, 2)
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, actions, 'Choose an action to play twice:', 1, 1)
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

end
