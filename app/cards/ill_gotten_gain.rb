class IllGottenGain < Card

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
    game.current_turn.add_coins(1)

    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        options = [
          { text: 'Yes', value: 'yes' },
          { text: 'No', value: 'no' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Gain a copper in hand?'.html_safe, 1, 1)
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
    }
  end

  def process_action(game, game_player, action)
    CardGainer.new(game, game_player, 'copper').gain_card('hand') if action.response == 'yes'
  end

  def gain_event(game, player, event)
    other_players = game.turn_ordered_players.reject{ |p| p.id == player.id }
    other_players.each do |other_player|
      give_card_to_player(game, other_player, 'curse', 'discard')
    end
  end

end
