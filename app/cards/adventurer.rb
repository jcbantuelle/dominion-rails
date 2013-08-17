module Adventurer

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 6
    }
  end

  def type
    [:action]
  end

  def play(game)
    reveal(game)
    discard_revealed(game)
  end

  private

  def reveal(game)
    @revealed = []
    @treasures = []

    reveal_cards(game)
    @log_updater.reveal(game.current_player, @revealed, 'deck')
  end

  def reveal_cards(game)
    game.current_player.deck.each do |card|
      break if @treasures.count == 2
      @revealed << card
      if card.treasure?
        @treasures << card
        card.update_attribute :state, 'hand'
      else
        card.update_attribute :state, 'revealed'
      end
    end

    continue_revealing(game) unless reveal_finished?(game)
  end

  def continue_revealing(game)
    game.current_player.shuffle_discard_into_deck
    reveal_cards(game)
  end

  def discard_revealed(game)
    game.current_player.discard_revealed
    @log_updater.put(game.current_player, @treasures, 'hand')
  end

  def reveal_finished?(game)
    @treasures.count == 2 || game.current_player.discard.count == 0
  end

end
