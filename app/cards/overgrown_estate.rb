module OvergrownEstate

  def cost(game, turn)
    {
      coin: 1
    }
  end

  def type
    [:victory, :shelter]
  end

  def value(deck)
    0
  end

  def results(player)
    card_html
  end

  def trash_reaction(game, player)
    CardDrawer.new(player).draw(1, true, self)
  end

end
