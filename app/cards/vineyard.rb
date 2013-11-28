class Vineyard < Card

  def starting_count(game)
    victory_card_count(game)
  end

  def cost(game, turn)
    {
      coin: 0,
      potion: 1
    }
  end

  def type
    [:victory]
  end

  def value(deck)
    action_count(deck) / 3
  end

  def results(deck)
    card_html + " (#{action_count(deck)} Actions)"
  end

  def action_count(deck)
    deck.select(&:action?).count
  end
end
