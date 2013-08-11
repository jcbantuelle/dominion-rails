module Adventurer

  def starting_count(game)
    10
  end

  def cost
    {
      coin: 6
    }
  end

  def type
    [:action]
  end

  def play(game)
    @revealed = []
    @treasures = []

    reveal_cards(game)
    discard_revealed
  end

  def log(game, player)
    locals = {
      revealed: {
        discarded: @revealed,
        drawn: @treasures
      }
    }

    render_play_card game, player, locals
  end

  private

  def reveal_cards(game)
    game.current_player.deck.each do |card|
      break if @treasures.count == 2
      if card.treasure?
        @treasures << card
        card.update_attribute :state, 'hand'
      else
        @revealed << card
        card.update_attribute :state, 'reveal'
      end
    end

    continue_revealing(game)
  end

  def continue_revealing(game)
    unless reveal_finished?
      shuffle_discard
      reveal_cards(game)
    end
  end

  def discard_revealed
    @revealed.each do |card|
      card.update_attribute :state, 'discard'
    end
  end

  def reveal_finished?
    @treasures.count == 2 || game.current_player.discard.count == 0
  end

end
