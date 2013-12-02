class Tunnel < Card

  def starting_count(game)
    victory_card_count(game)
  end

  def cost(game, turn)
    {
      coin: 3
    }
  end

  def type
    [:victory, :reaction]
  end

  def value(deck)
    2
  end

  def results(player)
    card_html
  end

  def discard_reaction(game, game_player, event, player_card)
    unless event == :cleanup
      options = [
        { text: 'Yes', value: 'yes' },
        { text: 'No', value: 'no' }
      ]
      action = TurnActionHandler.send_choose_text_prompt(game, game_player, options, "Reveal #{card_html}?".html_safe, 1, 1)
      TurnActionHandler.process_player_response(game, game_player, action, self)
      ActiveRecord::Base.connection.clear_query_cache
      TurnActionHandler.refresh_game_area(game, game_player.player)
    end
  end

  def process_action(game, game_player, action)
    CardGainer.new(game, game_player, 'gold').gain_card('discard') if action.response == 'yes'
  end
end
