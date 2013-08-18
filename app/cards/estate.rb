module Estate

  def starting_count(game)
    victory_card_count(game)
  end

  def cost(game)
    {
      coin: 2
    }
  end

  def type
    [:victory]
  end

  def value(deck)
    1
  end

  def results(player)
    card_html
  end
end
