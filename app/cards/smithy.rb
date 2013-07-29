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
    Renderer.new.render 'game/log/play_card', { game: game, player: player, card: self, card_drawer: @card_drawer }
  end
end
