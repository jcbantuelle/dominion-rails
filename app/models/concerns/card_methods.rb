module CardMethods

  def costs_less_than?(coin, potion)
    card_cost = calculated_cost(game, game.current_turn)
    (card_cost[:potion].nil? || card_cost[:potion] <= potion) && card_cost[:coin] < coin
  end

  def costs_same_as?(cost)
    card_cost = calculated_cost(game, game.current_turn)
    card_cost[:potion] == cost[:potion] && card_cost[:coin] == cost[:coin]
  end

end
