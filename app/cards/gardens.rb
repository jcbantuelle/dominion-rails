class Gardens

  def self.starting_count(game)
    game.player_count == 2 ? 8 : 12
  end

  def cost
    {
      coin: 4
    }
  end

  def type
    [:victory]
  end

  def value(deck)
    deck.length / 10
  end
end
