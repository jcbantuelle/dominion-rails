module Hovel

  def cost(game)
    {
      coin: 1
    }
  end

  def type
    [:reaction, :shelter]
  end

  def reaction(game, game_player, card)
    if card.card.victory_card?
      @reaction_thread = Thread.new {
        options = [
          { text: 'Yes', value: 'yes' },
          { text: 'No', value: 'no' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game_player, options, "Trash #{card_html}?".html_safe, 1, 1)
        TurnActionHandler.process_player_response(game, game_player, action, self)
        TurnActionHandler.refresh_game_area(game, game_player.player)
      }
    end
  end

  def process_action(game, game_player, action)
    if action.response == 'yes'
      card = game_player.find_card_in_hand('hovel')
      CardTrasher.new(game_player, [card]).trash('hand')
    end
  end

end
