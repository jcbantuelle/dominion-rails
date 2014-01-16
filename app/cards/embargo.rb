class Embargo < Card

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
        trash_embargo(game) unless clone
        add_embargo_token(game)
      end
    }
  end

  def trash_embargo(game)
    embargo = game.current_player.find_card_in_play('embargo')
    CardTrasher.new(game.current_player, [embargo]).trash
  end

  def add_embargo_token(game)
    supply_cards = game.supply_cards
    action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, supply_cards, 'Choose a card to embargo:', 1, 1)
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def process_action(game, game_player, action)
    card = GameCard.find(action.response)
    card.add_embargo
    LogUpdater.new(game).custom_message(game_player, card.card.card_html.html_safe, 'embargo')
  end
end
