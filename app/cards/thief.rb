module Thief

  def starting_count(game)
    10
  end

  def cost
    {
      coin: 4
    }
  end

  def type
    [:action, :attack]
  end

  def play
    # Each other player reveals top 2 cards. If any treasure revealed, you choose 1 to trash. You may gain trashed card. Discard other revealed cards
  end
end
