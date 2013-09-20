module Ironmonger

  def starting_count(game)
    10
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

    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        reveal(game)
        discard_card(game, game.current_player) unless @revealed.empty?
        gain_from_revealed(game) unless @revealed.empty?
        ActiveRecord::Base.connection.clear_query_cache
        TurnActionHandler.refresh_game_area(game, game.current_player.player)
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

  def gain_from_revealed(game)
    actions = 0
    coins = 0
    cards = 0
    gain = []

    card = @revealed.first

    if card.card.action_card?
      game.current_turn.add_actions(1)
      actions += 1
    end
    if card.card.treasure_card?
      game.current_turn.add_coins(1)
      coins += 1
    end
    if card.card.victory_card?
      cards += 1
    end

    CardDrawer.new(game.current_player).draw(cards) unless cards == 0
    gain << "+#{actions} actions" unless actions == 0
    gain << "+#{coins} coins" unless coins == 0
    LogUpdater.new(game).get_from_card(game.current_player, gain.join(', ')) unless gain.empty?
  end

  def reveal(game)
    @revealed = []
    reveal_cards(game, game.current_player)
    @log_updater.reveal(game.current_player, @revealed, 'deck')
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 1
  end

  def reveal_finished?(game, player)
    @revealed.count == 1 || game.current_player.discard.count == 0
  end
end
