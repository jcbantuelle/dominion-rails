module Colony

  def starting_count(game)
    victory_card_count(game)
  end

  def cost
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
end
