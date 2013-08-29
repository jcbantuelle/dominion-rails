module FarmingVillage

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

  def play(game)
    game.current_turn.add_actions(2)
    @log_updater.get_from_card(game.current_player, '+2 action')

    reveal(game)
  end

  private

  def reveal(game)
    @revealed = []
    reveal_cards(game, game.current_player)
    @log_updater.reveal(game.current_player, @revealed, 'deck')
    discard_revealed(game)
  end

  def process_revealed_card(card)
    if valid_card?(card)
      @valid_card = card
      @valid_card.update_attribute :state, 'hand'
    else
      card.update_attribute :state, 'revealed'
    end
    valid_card?(card)
  end

  def discard_revealed(game)
    game.current_player.discard_revealed
    @log_updater.put(game.current_player, [@valid_card], 'hand')
  end

  def reveal_finished?(game, player)
    @valid_card.present? || game.current_player.discard.count == 0
  end

  def valid_card?(card)
    card.action? || card.treasure?
  end

end
