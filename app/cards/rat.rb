module Rat

  def starting_count(game)
    20
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(1)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')
    CardGainer.new(game, game.current_player, 'rats').gain_card('discard')

    available_cards = game.current_player.hand.select{ |card| card.name != 'rats' }
    if available_cards.count == 0
      @log_updater.reveal(game.current_player, game.current_player.hand, 'hand')
    elsif available_cards.count == 1
      CardTrasher.new(game.current_player, available_cards).trash('hand')
    else
      @play_thread = Thread.new {
        ActiveRecord::Base.connection_pool.with_connection do
          action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, available_cards, 'Choose a card to trash:', 1, 1)
          TurnActionHandler.process_player_response(game, game.current_player, action, self)
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, game.current_player.player)
        end
      }
    end
  end

  def process_action(game, game_player, action)
    trashed_card = PlayerCard.find action.response
    CardTrasher.new(game_player, [trashed_card]).trash('hand')
  end

  def trash_reaction(game, player)
    CardDrawer.new(player).draw(1, true, self)
  end

end
