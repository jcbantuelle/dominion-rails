class Procession < Card

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
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        prompt_player_response(game)
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'trash'
      unless action.response.empty?
        card = PlayerCard.find action.response
        play_card_twice(game, game_player, card)
        trash_card(game, game_player, card)
        gain_card(game, game_player, card)
      end
    elsif action.action == 'gain'
      card = GameCard.find(action.response)
      CardGainer.new(game, game_player, card.name).gain_card('discard')
    end
  end

  def play_card_twice(game, game_player, card)
    play_card_multiple_times(game, game_player, card, 2)
  end

  def trash_card(game, game_player, card)
    CardTrasher.new(game.current_player, [card]).trash('hand')
  end

  def gain_card(game, game_player, card)
    card_cost = card.calculated_cost(game, game.current_turn)
    available_cards = game.cards_equal_to({coin: card_cost[:coin]+1, potion: card_cost[:potion]})
    if available_cards.count == 0
      @log_updater.custom_message(nil, 'But there are no available cards to gain')
    elsif available_cards.count == 1
      CardGainer.new(game, game_player, available_cards.first.name).gain_card('discard')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, available_cards, 'Choose a card to gain:', 1, 1, 'gain')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  private

  def prompt_player_response(game)
    actions = game.current_player.hand.select(&:action?)
    if actions.count == 0
      @log_updater.custom_message(game.current_player, 'no actions to play', 'have')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, actions, 'Choose an action to play twice:', 1, 0, 'trash')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

end
