module Smithy

  def starting_count(game)
    10
  end

  def cost
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game)
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(3)
  end

  def log(game, player)
    render_play_card game, player, nil, @card_drawer
  end
end
