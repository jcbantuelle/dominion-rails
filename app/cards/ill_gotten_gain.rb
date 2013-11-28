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
    if action.response == 'yes'
      CardGainer.new(game, game_player, 'copper').gain_card('hand')
    end
  end

  def gain_event(game, player)
    game.game_players.each do |game_player|
      CardGainer.new(game, game_player, 'curse').gain_card('discard') unless game_player.id == player.id
    end
  end

end
