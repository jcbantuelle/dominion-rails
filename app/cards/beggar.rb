class Beggar < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 2
    }
  end

  def type
    [:action, :reaction]
  end

  def play(game, clone=false)
    3.times do
      give_card_to_player(game, game.current_player, 'copper', 'hand')
    end
  end

  def process_action(game, game_player, action)
    if action.response == 'yes'
      beggar = game_player.find_card_in_hand('beggar')
      CardDiscarder.new(game_player, [beggar]).discard('hand')
      give_card_to_player(game, game.current_player, 'silver', 'discard')
      give_card_to_player(game, game.current_player, 'silver', 'deck')
      ActiveRecord::Base.connection.clear_query_cache
      TurnActionHandler.refresh_game_area(game, game_player.player)
    end
  end

  def reaction(game, game_player)
    @reaction_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        options = [
          { text: 'Yes', value: 'yes' },
          { text: 'No', value: 'no' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game_player, options, "Discard #{card_html}?".html_safe, 1, 1)
        TurnActionHandler.process_player_response(game, game_player, action, self)
      end
    }
  end

end
