module Garden

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
    deck.length / 10
  end

  def results(deck)
    card_html + " (#{deck.length} Cards)"
  end
end
