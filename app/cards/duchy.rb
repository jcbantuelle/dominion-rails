module Duchy

  def starting_count(game)
    victory_card_count(game)
  end

  def cost(game)
    {
      coin: 5
    }
  end

  def type
    [:victory]
  end

  def value(deck)
    3
  end

  def results(player)
    card_html
  end
end
