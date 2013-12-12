class TrustySteed < Card

  def starting_count(game)
    1
  end

  def cost(game, turn)
    {
      coin: 0
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
          { text: '+2 actions', value: 'action' },
          { text: '+$2', value: 'coin' },
          { text: 'Gain 4 Silvers and discard deck', value: 'silver' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Choose two:', 2, 2, 'pick')
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
    }
  end

  def process_action(game, game_player, action)
    actions = action.response.split
    actions.each do |choice|
      if choice == 'card'
        CardDrawer.new(game_player).draw(2)
      elsif choice == 'action'
        game.current_turn.add_actions(2)
        LogUpdater.new(game).get_from_card(game_player, '+2 actions')
      elsif choice == 'coin'
        game.current_turn.add_coins(2)
        LogUpdater.new(game).get_from_card(game_player, '+$2')
      elsif choice == 'silver'
        4.times do
          CardGainer.new(game, game_player, 'silver').gain_card('discard')
        end
        game_player.deck.update_all state: 'discard'
        LogUpdater.new(game).custom_message(game_player, 'deck into discard', 'put')
      end
    end
  end

end
