module Spy

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 4
    }
  end

  def type
    [:action, :attack]
  end

  def play
    # +1 Card
    # +1 Action
    # Each Player reveals top card of deck, puts back or discards (your choice)
  end
end
