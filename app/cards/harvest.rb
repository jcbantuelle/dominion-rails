module Harvest

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play(game)
    reveal(game)

    unique_reveals = @revealed.map(&:name).uniq.count
    game.current_turn.add_coins(unique_reveals)
    @log_updater.get_from_card(game.current_player, "+$#{unique_reveals}")
  end

  private

  def reveal(game)
    @revealed = []
    reveal_cards(game)
    @log_updater.reveal(game.current_player, @revealed, 'deck')
    discard_revealed(game)
  end

  def reveal_cards(game)
    game.current_player.deck.each do |card|
      @revealed << card
      card.update_attribute :state, 'revealed'
      break if @revealed.count == 4
    end

    continue_revealing(game) unless reveal_finished?(game)
  end

  def continue_revealing(game)
    game.current_player.shuffle_discard_into_deck
    reveal_cards(game)
  end

  def discard_revealed(game)
    game.current_player.discard_revealed
  end

  def reveal_finished?(game)
    @revealed.count == 4 || game.current_player.discard.count == 0
  end

end
