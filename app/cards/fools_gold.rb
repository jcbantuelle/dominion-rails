module FoolsGold

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 2
    }
  end

  def type
    [:treasure, :reaction]
  end

  def play(game, clone=false)
    game.current_turn.add_fools_gold
    coins = game.current_turn.fools_gold > 1 ? 4 : 1
    game.current_turn.add_coins(coins)
    @log_updater.get_from_card(game.current_player, "+$#{coins}")
  end

  def reaction(game, game_player, card)
    if game_player.id != game.current_player.id && card.name == 'province'
      @reaction_thread = Thread.new {
        ActiveRecord::Base.connection_pool.with_connection do
          options = [
            { text: 'Yes', value: 'yes' },
            { text: 'No', value: 'no' }
          ]
          action = TurnActionHandler.send_choose_text_prompt(game, game_player, options, 'Trash Fools Gold?'.html_safe, 1, 1)
          TurnActionHandler.process_player_response(game, game_player, action, self)
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, game_player.player)
        end
      }
    end
  end

  def process_action(game, game_player, action)
    if action.response == 'yes'
      fools_gold = game_player.find_card_in_hand('fools_gold')
      CardTrasher.new(game_player, [fools_gold]).trash
      card_gainer = CardGainer.new(game, game_player, 'gold').gain_card('deck')
    end
  end

end
