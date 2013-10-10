module Duchess

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 2
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    game.current_turn.add_coins(2)
    @log_updater.get_from_card(game.current_player, '+$2')

    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        game.turn_ordered_players.each do |game_player|
          reveal(game, game_player)
          @log_updater.reveal(game_player, @revealed, 'deck')
          discard_card(game, game_player) unless @revealed.empty?
          TurnActionHandler.wait_for_response(game)
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, game_player.player)
        end
      end
    }
  end

  def discard_card(game, game_player)
    options = [
      { text: 'Yes', value: 'yes' },
      { text: 'No', value: 'no' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(game, game_player, options, "Discard #{@revealed.first.card.card_html}?".html_safe, 1, 1)
    TurnActionHandler.process_player_response(game, game_player, action, self)
  end

  def process_action(game, game_player, action)
    if action.response == 'yes'
      CardDiscarder.new(game_player, @revealed).discard
    else
      @revealed.first.update state: 'deck'
      @log_updater.put(game_player, @revealed, 'deck', false)
    end
  end

  private

  def reveal(game, player)
    @revealed = []
    reveal_cards(game, player)
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 1
  end

  def reveal_finished?(game, player)
    @revealed.count == 1 || player.discard.count == 0
  end

end
