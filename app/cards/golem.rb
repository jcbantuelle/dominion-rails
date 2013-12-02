class Golem < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 4,
      potion: 1
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    reveal(game)
    play_actions(game) unless @actions.empty?
  end

  def reveal(game)
    @revealed = []
    @actions = []
    reveal_cards(game, game.current_player)
    @log_updater.reveal(game.current_player, @revealed, 'deck')
    discard_revealed(game)
  end

  def process_revealed_card(card)
    if card.action? && card.name != 'golem'
      @actions << card
    else
      card.update_attribute :state, 'revealed'
    end
    @actions.count == 2
  end

  def discard_revealed(game)
    revealed_cards = game.current_player.player_cards.revealed
    CardDiscarder.new(game.current_player, revealed_cards).discard
  end

  def reveal_finished?(game, player)
    @actions.count == 2 || game.current_player.discard.count == 0
  end

  def play_actions(game)
    if @actions.count == 1
      CardPlayer.new(game, @actions.first.card_id, true, false, @actions.first.id).play_card
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, @actions, 'Choose which action to play first:', 1, 1, 'play')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'play'
      first_card = PlayerCard.find(action.response)
      card = CardPlayer.new(game, first_card.card_id, true, false, first_card.id).play_card
      TurnActionHandler.wait_for_card(card)
      second_card = @actions.select{|c| c.id != first_card.id}.first
      card = CardPlayer.new(game, second_card.card_id, true, false, second_card.id).play_card
      TurnActionHandler.wait_for_card(card)
    end
  end

end
