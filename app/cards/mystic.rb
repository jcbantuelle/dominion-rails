class Mystic < Card

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
    game.current_turn.add_actions(1)
    game.current_turn.add_coins(2)
    @log_updater.get_from_card(game.current_player, '+1 action and +$2')

    if game.current_player.deck.count > 0 || game.current_player.discard.count > 0
      @play_thread = Thread.new {
        ActiveRecord::Base.connection_pool.with_connection do
          name_card(game)
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, game.current_player.player)
        end
      }
    else
      @log_updater.custom_message(game.current_player, 'no cards to reveal', 'has')
    end
  end

  def name_card(game)
    options = game.card_names
    action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Choose a card to name:', 1, 1)
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def process_action(game, game_player, action)
    named_card = Card.by_name(action.response)
    LogUpdater.new(game).custom_message(game_player, "#{named_card.card_html}".html_safe, 'name')
    reveal(game, game.current_player)
    @log_updater.reveal(game.current_player, @revealed, 'deck')
    revealed_card = @revealed.first
    if revealed_card.name == named_card.name
      revealed_card.update state: 'hand'
      LogUpdater.new(game).put(game_player, @revealed, 'hand', false)
    end
  end

  private

  def reveal(game, player)
    @revealed = []
    reveal_cards(game, player)
  end

  def process_revealed_card(card)
    @revealed.count == 1
  end

  def reveal_finished?(game, player)
    @revealed.count == 1 || player.discard.count == 0
  end

end
