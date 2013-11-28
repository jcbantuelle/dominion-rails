class MarketSquare < MarketCard

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 3
    }
  end

  def type
    [:action, :reaction]
  end

  def play(game, clone=false)
    market(game)
    @log_updater.get_from_card(game.current_player, '+1 action and +1 buy')
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

  def process_action(game, game_player, action)
    if action.response == 'yes'
      market_square = game_player.find_card_in_hand('market_square')
      unless market_square.nil?
        CardDiscarder.new(game_player, [market_square]).discard('hand')
        give_card_to_player(game, game_player, 'gold', 'discard')
        ActiveRecord::Base.connection.clear_query_cache
        TurnActionHandler.refresh_game_area(game, game_player.player)
      end
    end
  end

end
