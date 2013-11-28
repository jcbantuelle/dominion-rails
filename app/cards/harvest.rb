class Harvest < Card

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
    reveal(game)

    unique_reveals = @revealed.map(&:name).uniq.count
    game.current_turn.add_coins(unique_reveals)
    @log_updater.get_from_card(game.current_player, "+$#{unique_reveals}")
  end

  private

  def reveal(game)
    @revealed = []
    reveal_cards(game, game.current_player)
    @log_updater.reveal(game.current_player, @revealed, 'deck')
    discard_revealed(game)
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 4
  end

  def discard_revealed(game)
    revealed_cards = game.current_player.player_cards.revealed
    CardDiscarder.new(game.current_player, revealed_cards).discard
  end

  def reveal_finished?(game, player)
    @revealed.count == 4 || game.current_player.discard.count == 0
  end

end
