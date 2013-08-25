module SilkRoad

  def starting_count(game)
    game.player_count == 2 ? 8 : 12
  end

  def cost(game)
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
