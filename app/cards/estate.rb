module Estate

  def starting_count(game)
    victory_card_count(game)
  end

  def cost
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
end
