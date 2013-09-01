module Harem

  def starting_count(game)
    victory_card_count(game)
  end

  def cost(game)
    {
      coin: 6
    }
  end

  def type
    [:treasure, :victory]
  end

  def value(deck)
    2
  end

  def play(game, clone=false)
    game.current_turn.add_coins(2)
  end

  def results(deck)
    card_html
  end

end
