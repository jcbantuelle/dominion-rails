module Province

  def starting_count(game)
    victory_card_count(game)
  end

  def cost
    {
      coin: 8
    }
  end

  def type
    [:victory]
  end

  def value(deck)
    6
  end
end
