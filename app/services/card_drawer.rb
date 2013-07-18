class CardDrawer

  def self.draw(game_player, count = 1)
    move_to_hand(game_player, count)
    adjust_deck_order(game_player)
  end

  private

  def self.move_to_hand(game_player, count)
    game_player.deck.limit(count).update_all(state: 'hand', card_order: nil)
  end

  def self.adjust_deck_order(game_player)
    first_card = game_player.deck.first
    if first_card
      offset = first_card.card_order - 1
      game_player.deck.update_all ['card_order = card_order - ?', offset]
    end
  end
end
