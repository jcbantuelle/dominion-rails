class Sage < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 3
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')

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
    @log_updater.put(game.current_player, [@valid_card], 'hand', false)
    revealed_cards = game.current_player.player_cards.revealed
    CardDiscarder.new(game.current_player, revealed_cards).discard
  end

  def reveal_finished?(game, player)
    @valid_card.present? || game.current_player.discard.count == 0
  end

  def valid_card?(card)
    game = card.game_player.game
    card.calculated_cost(game, game.current_turn)[:coin] > 2
  end

end
