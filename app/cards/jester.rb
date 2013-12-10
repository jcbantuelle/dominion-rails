class Jester < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action, :attack]
  end

  def play(game, clone=false)
    game.current_turn.add_coins(2)
    @log_updater.get_from_card(game.current_player, '+$2')
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
    CardDiscarder.new(game_player, @revealed).discard
    if @revealed.first.victory?
      give_card_to_player(game, game_player, 'curse', 'discard')
    else
      options = [
        { text: "You", value: 'you' },
        { text: 'Opponent', value: 'opponent' }
      ]
      action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, "Who gains a copy of #{@revealed.first.card.card_html}?".html_safe, 1, 1, 'gain')
      TurnActionHandler.process_player_response(game, game_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'gain'
      receiving_player = action.response == 'you' ? game.current_player : game_player
      give_card_to_player(game, receiving_player, @revealed.first.name, 'discard')
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
