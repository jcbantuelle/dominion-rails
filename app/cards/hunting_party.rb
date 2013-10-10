module HuntingParty

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
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(1)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')

    reveal(game)
  end

  private

  def reveal(game)
    @revealed = []
    reveal_hand(game)
    reveal_cards(game, game.current_player)
    @log_updater.reveal(game.current_player, @revealed, 'deck')
    discard_revealed(game)
  end

  def reveal_hand(game)
    @hand = game.current_player.player_cards.hand
    @hand_names = @hand.map(&:name).uniq
    @log_updater.reveal(game.current_player, @hand, 'hand')
  end

  def process_revealed_card(card)
    if unique_card?(card)
      @unique_card = card
      @unique_card.update_attribute :state, 'hand'
    else
      card.update_attribute :state, 'revealed'
    end
    unique_card?(card)
  end

  def discard_revealed(game)
    @log_updater.put(game.current_player, [@unique_card], 'hand', false)
    revealed_cards = game.current_player.player_cards.revealed
    CardDiscarder.new(game.current_player, revealed_cards).discard
  end

  def reveal_finished?(game, player)
    @unique_card.present? || game.current_player.discard.count == 0
  end

  def unique_card?(card)
    @hand_names.select{ |name| name == card.name }.count == 0
  end

end
