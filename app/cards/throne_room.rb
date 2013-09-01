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

  private

  def prompt_player_response(game)
    actions = game.current_player.hand.select(&:action?)
    if actions.count == 0
      @log_updater.custom_message(game.current_player, 'no actions to play', 'have')
    elsif actions.count == 1
      play_card_twice(game, actions.first)
    else
      action = send_choose_cards_prompt(game, game.current_player, actions, 'Choose an action to play twice:', 1, 1)
      process_player_response(game, game.current_player, action)
    end
  end

  def process_action(game, game_player, action)
    play_card_twice(game, PlayerCard.find(action.response))
  end

  def play_card_twice(game, card)
    first_card = CardPlayer.new(game, card.card_id, true, false).play_card
    wait_for_card(first_card)
    second_card = CardPlayer.new(game, card.card_id, true, true).play_card
    wait_for_card(second_card)
    game.players.each do |player|
      WebsocketDataSender.send_game_data player, game, play_card_json(game, player)
    end
  end

end
