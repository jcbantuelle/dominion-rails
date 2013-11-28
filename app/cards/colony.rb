class Colony < Card

  def starting_count(game)
    victory_card_count(game)
  end

  def cost(game, turn)
    {
      coin: 11
    }
  end

  def type
    [:victory]
  end

  def value(deck)
    10
  end

  def results(player)
    card_html
  end
end
