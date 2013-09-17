module Feodum

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
    silver_count(deck) / 3
  end

  def results(deck)
    card_html + " (#{silver_count(deck)} Silver)"
  end

  def silver_count(deck)
    deck.select{ |card| card.name == 'silver' }.count
  end

  def trash_reaction(game, player)
    3.times do
      give_card_to_player(game, player, 'silver', 'discard')
    end
  end
end
