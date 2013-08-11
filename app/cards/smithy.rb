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
    locals = {
      card_drawer: @card_drawer
    }
    render_play_card game, player, locals
  end
end
