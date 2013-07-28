class CardDrawer

  attr_accessor :drawn_cards

  def initialize(player)
    @player = player
    @drawn_cards = []
  end

  def draw(count)
    move_to_hand(count)
    adjust_deck_order
  end

  private

  def move_to_hand(count)
    cards = @player.deck.limit(count)
    card_count = cards.count

    @drawn_cards += cards
    cards.update_all(state: 'hand', card_order: nil)

    if card_count < count && @player.discard.count > 0
      shuffle_discard_into_deck
      move_to_hand(count - card_count)
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
