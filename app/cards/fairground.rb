module Fairground

  def starting_count(game)
    game.player_count == 2 ? 8 : 12
  end

  def cost(game)
    {
      coin: 6
    }
  end

  def type
    [:victory]
  end

  def value(deck)
    (unique_cards(deck) / 5) * 2
  end

  def results(deck)
    card_html + " (#{unique_cards(deck)} Unique Cards)"
  end

  private

  def unique_cards(deck)
    deck.map(&:name).uniq.count
  end
end
