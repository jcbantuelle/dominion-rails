class Hovel < Card

  def cost(game, turn)
    {
      coin: 1
    }
  end

  def type
    [:reaction, :shelter]
  end

  def reaction(game, game_player, card)
    if game_player.id == game.current_player.id && card.card.victory_card?
      @reaction_thread = Thread.new {
        ActiveRecord::Base.connection_pool.with_connection do
          options = [
            { text: 'Yes', value: 'yes' },
            { text: 'No', value: 'no' }
          ]
          action = TurnActionHandler.send_choose_text_prompt(game, game_player, options, "Trash #{card_html}?".html_safe, 1, 1)
          TurnActionHandler.process_player_response(game, game_player, action, self)
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, game_player.player)
        end
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
