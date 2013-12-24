class CountingHouse < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        LogUpdater.new(game).look(game.current_player, game.current_player.discard, 'discard')
        choose_copper(game)
      end
    }
  end

  def choose_copper(game)
    coppers = game.current_player.discard.select{ |c| c.name == 'copper' }
    unless coppers.empty?
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, coppers, 'Choose any number of copper to put in hand:')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    gained_copper = PlayerCard.where(id: action.response.split)
    unless gained_copper.empty?
      gained_copper.each do |copper|
        copper.update_attribute :state, 'hand'
      end
      ActiveRecord::Base.connection.clear_query_cache
      TurnActionHandler.refresh_game_area(game, game_player.player)
    end
    LogUpdater.new(game).put(game_player, gained_copper, 'hand', false, announce=true)
  end

end
