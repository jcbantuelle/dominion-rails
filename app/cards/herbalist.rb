class Herbalist < Card

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
    game.current_turn.add_coins(1)
    game.current_turn.add_buys(1)
    @log_updater.get_from_card(game.current_player, '+1 buy and +$1')
  end

  def discard_reaction(game, game_player, event)
    if event == :cleanup
      treasures = game_player.in_play.select(&:treasure?)
      if treasures.count == 0
        LogUpdater.new(game).custom_message(nil, 'But there are no treasures in play')
      else
        action = TurnActionHandler.send_choose_cards_prompt(game, game_player, treasures, 'You may choose a treasure to put on deck:', 1, 0, 'deck')
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'deck' && action.response.present?
      card = PlayerCard.find(action.response)
      put_card_on_deck(game, game_player, card, true)
    end
  end

end
