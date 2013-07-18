class CardDrawer

  def self.draw(player, count = 1)
    move_to_hand(player, count)
    adjust_deck_order(player)
  end

  private

  def self.move_to_hand(player, count)
    player.player_cards.deck.limit(count).update_all(state: 'hand', card_order: nil)
  end

  def self.adjust_deck_order(player)
    first_card = player.player_cards.deck.first
    if first_card
      offset = first_card.card_order - 1
      player.player_cards.deck.update_all ['card_order = card_order - ?', offset]
    end
  end
end
