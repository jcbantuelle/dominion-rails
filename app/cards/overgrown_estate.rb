module OvergrownEstate

  def cost(game)
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

  def trash_reaction(game)
    CardDrawer.new(game.current_player).draw(1, true, self)
  end

end
