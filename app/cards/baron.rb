module Baron

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    game.current_turn.add_buys(1)
    @log_updater.get_from_card(game.current_player, '+1 buy')

    estate = game.current_player.find_card_in_hand('estate')
    if estate.nil?
      CardGainer.new(game, game.current_player, 'estate').gain_card('discard')
    else
      @play_thread = Thread.new {
        ActiveRecord::Base.connection_pool.with_connection do
          discard_estate(game, game.current_player)
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, game.current_player.player)
        end
      }
    end
  end

  def discard_estate(game, game_player)
    options = [
      { text: 'Yes', value: 'yes' },
      { text: 'No', value: 'no' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, "Discard an estate?".html_safe, 1, 1)
    TurnActionHandler.process_player_response(game, game_player, action, self)
  end

  def process_action(game, game_player, action)
    if action.response == 'yes'
      estate = game_player.find_card_in_hand('estate')
      estate.discard
      @log_updater.discard(game_player, [estate])
      game.current_turn.add_coins(4)
      @log_updater.get_from_card(game_player, '+$4')
    else
      CardGainer.new(game, game_player, 'estate').gain_card('discard')
    end
  end

end
