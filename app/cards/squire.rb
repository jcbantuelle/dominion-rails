module Squire

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 2
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    game.current_turn.add_coins(1)
    LogUpdater.new(game).get_from_card(game.current_player, '+$1')

    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        options = [
          { text: '+2 actions', value: 'action' },
          { text: '+2 buys', value: 'buy' },
          { text: 'Gain a Silver', value: 'silver' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Choose one:', 1, 1, 'pick')
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'gain'
      card = GameCard.find(action.response)
      CardGainer.new(game, game_player, card.name).gain_card('discard')
    elsif action.action == 'pick'
      if action.response == 'action'
        game.current_turn.add_actions(2)
        LogUpdater.new(game).get_from_card(game.current_player, '+2 actions')
      elsif action.response == 'buy'
        game.current_turn.add_buys(2)
        LogUpdater.new(game).get_from_card(game.current_player, '+2 buys')
      elsif action.response == 'silver'
        CardGainer.new(game, game_player, 'silver').gain_card('discard')
      end
    end
  end

  def trash_reaction(game, player)
    available_cards = game.game_cards.select(&:attack_card?)
    if available_cards.count == 0
      LogUpdater.new(game).custom_message(nil, 'But there are no attack to gain')
    elsif available_cards.count == 1
      CardGainer.new(game, player, available_cards.first.name).gain_card('discard')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, player, available_cards, 'Choose an attack card to gain:', 1, 1, 'gain')
      TurnActionHandler.process_player_response(game, player, action, self)
    end
  end

end
