module Venture

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 5
    }
  end

  def type
    [:treasure]
  end

  def play(game)
    game.current_turn.add_coins(1)
    @log_updater.get_from_card(game.current_player, '+$1')
    reveal(game)
    discard_revealed(game)
    play_treasure(game) unless @treasure.nil?
  end

  private

  def reveal(game)
    @revealed = []
    reveal_cards(game)
    @log_updater.reveal(game.current_player, @revealed, 'deck')
  end

  def reveal_cards(game)
    game.current_player.deck.each do |card|
      @revealed << card
      if card.treasure?
        @treasure = card
        break
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
    @log_updater.put(game.current_player, [@treasure], 'play')
  end

  def reveal_finished?(game)
    @treasure.present? || game.current_player.discard.count == 0
  end

  def play_treasure(game)
    @treasure.update_attribute :state, 'play'
    game.current_player.player_cards.reload
    played_card = @treasure.card
    played_card.log_updater = LogUpdater.new game
    played_card.play(game)
  end
end
