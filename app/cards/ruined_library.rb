class RuinedLibrary < Card

  def cost(game, turn)
    {
      coin: 0
    }
  end

  def type
    [:action, :ruin]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(1)
  end

end
