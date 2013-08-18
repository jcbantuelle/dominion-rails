module Vineyard

  def starting_count(game)
    game.player_count == 2 ? 8 : 12
  end

  def cost(game)
    {
      coin: 0,
      potion: 1
    }
  end

  def type
    [:victory]
  end

  def value(deck)
    action_count(deck) / 3
  end

  def results(deck)
    card_html + " (#{action_count(deck)} Actions)"
  end

  def action_count(deck)
    deck.select(&:action?).count
  end
end
