class Duke < Card

  def starting_count(game)
    victory_card_count(game)
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:victory]
  end

  def value(deck)
    duchy_count(deck)
  end

  def results(deck)
    card_html + " (#{duchy_count(deck)} Duchies)"
  end

  def duchy_count(deck)
    duchy = Card.by_name('duchy')
    deck.select{|card| card.card_id == duchy.id }.count
  end

end
