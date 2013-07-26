class CardDrawer

  def initialize(player)
    @player = player
  end

  def draw(count)
    move_to_hand(count)
    adjust_deck_order
  end

  private

  def move_to_hand(count)
    drawn_card_count = @player.deck.limit(count).update_all(state: 'hand', card_order: nil)
    if drawn_card_count < count && @player.discard.count > 0
      shuffle_discard_into_deck
      move_to_hand(count - drawn_card_count)
    end
  end

  def adjust_deck_order
    first_card = @player.deck.first
    if first_card
      offset = first_card.card_order - 1
      @player.deck.update_all ['card_order = card_order - ?', offset]
    end
  end

  def shuffle_discard_into_deck
    @player.discard.shuffle.each_with_index do |card, index|
      card.update(card_order: index+1, state: 'deck')
    end
  end
end
