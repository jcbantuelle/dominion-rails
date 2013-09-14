module SilkRoad

  def starting_count(game)
    victory_card_count(game)
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:victory]
  end

  def value(deck)
    victory_count(deck) / 4
  end

  def results(deck)
    card_html + " (#{victory_count(deck)} Victory Cards)"
  end

  def victory_count(deck)
    deck.select(&:victory?).count
  end
end
