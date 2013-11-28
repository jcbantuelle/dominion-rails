class Duchy < Card

  def starting_count(game)
    victory_card_count(game)
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:victory]
  end

  def value(deck)
    3
  end

  def results(player)
    card_html
  end

  def gain_event(game, player, event)
    if game.has_duchess?
      options = [
        { text: 'Yes', value: 'yes' },
        { text: 'No', value: 'no' }
      ]
      action = TurnActionHandler.send_choose_text_prompt(game, player, options, 'Gain a Duchess?'.html_safe, 1, 1)
      TurnActionHandler.process_player_response(game, player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.response == 'yes'
      card_gainer = CardGainer.new(game, game_player, 'duchess').gain_card('discard')
    end
  end
end
