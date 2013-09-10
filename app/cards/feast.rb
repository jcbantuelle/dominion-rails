module Feast

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
    @play_thread = Thread.new {
      feast = game.current_player.find_card_in_play('feast')
      CardTrasher.new(game.current_player, [feast]).trash
      available_cards = game.cards_costing_less_than(6)
      if available_cards.count == 0
        @log_updater.custom_message(nil, 'But there are no available cards to gain')
      else
        action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, available_cards, 'Choose a card to gain:', 1, 1)
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
      ActiveRecord::Base.clear_active_connections!
    }
  end

  def process_action(game, game_player, action)
    card = GameCard.find(action.response)
    CardGainer.new(game, game_player, card.name).gain_card('discard')
    game.reload
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end
end
