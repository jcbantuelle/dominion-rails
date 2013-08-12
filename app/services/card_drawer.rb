class CardDrawer

  attr_accessor :drawn_cards

  def initialize(player)
    @player = player
    @drawn_cards = []
  end

  def draw(count, end_turn = false)
    move_to_hand(count)
    LogUpdater.new(@player.game).draw(@drawn_cards, @player) unless end_turn
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

  def shuffle_discard_into_deck
    @player.discard.shuffle.each_with_index do |card, index|
      card.update(card_order: index+1, state: 'deck')
    end
  end
end
