module Spy

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:action, :attack]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(1)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')

    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        reveal(game, game.current_player)
        @log_updater.reveal(game.current_player, @revealed, 'deck')
        discard_card(game, game.current_player) unless @revealed.empty?
        ActiveRecord::Base.connection.clear_query_cache
        TurnActionHandler.refresh_game_area(game, game.current_player.player)
      end
    }
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        players.each do |player|
          reveal(game, player)
          @log_updater.reveal(player, @revealed, 'deck')
          discard_card(game, player) unless @revealed.empty?
          TurnActionHandler.wait_for_response(game)
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, player.player)
        end
      end
    }
  end

  def discard_card(game, game_player)
    options = [
      { text: 'Yes', value: 'yes' },
      { text: 'No', value: 'no' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, "Discard #{@revealed.first.card.card_html}?".html_safe, 1, 1)
    TurnActionHandler.process_player_response(game, game_player, action, self)
  end

  def process_action(game, game_player, action)
    if action.response == 'yes'
      game_player.discard_revealed
      @log_updater.discard(game_player, @revealed)
    else
      @revealed.first.update state: 'deck'
      @log_updater.put(game_player, @revealed, 'deck', false)
    end
  end

  private

  def reveal(game, player)
    @revealed = []
    reveal_cards(game, player)
    player.discard_revealed
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 1
  end

  def reveal_finished?(game, player)
    @revealed.count == 1 || player.discard.count == 0
  end

end
