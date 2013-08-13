class CardDrawer

  attr_accessor :drawn_cards

  def initialize(player)
    @player = player
    @drawn_cards = []
  end

  def draw(count, update_log = true)
    move_to_hand(count)
    LogUpdater.new(@player.game).draw(@drawn_cards, @player) if update_log
  end

  private

  def move_to_hand(count)
    cards = @player.deck.limit(count)
    card_count = cards.count

    @drawn_cards += cards
    cards.update_all(state: 'hand', card_order: nil)

    if card_count < count && @player.discard.count > 0
      @player.shuffle_discard_into_deck
      move_to_hand(count - card_count)
    end
  end

end
