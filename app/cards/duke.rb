module Duke

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
    duchy = Card.by_name('duchy')
    deck.select{|card| card.card_id == duchy.id }.count
  end

end
