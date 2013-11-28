class DameNatalie < Knight

  def play(game, clone=false)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        available_cards = game.cards_costing_less_than(4)
        if available_cards.count == 0
          @log_updater.custom_message(nil, 'But there are no available cards to gain')
        else
          action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, available_cards, 'Choose a card to gain:', 1, 1, 'gain')
          TurnActionHandler.process_player_response(game, game.current_player, action, self)
        end
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'trash'
      knight_trash(game, game_player, action)
    elsif action.action == 'gain'
      card = GameCard.find action.response
      CardGainer.new(game, game_player, card.name).gain_card('discard')
    end
  end

  def trash_self(game)
    card_to_trash = game.current_player.find_card_in_play('dame_natalie')
    CardTrasher.new(game.current_player, [card_to_trash]).trash unless card_to_trash.nil?
  end

end
