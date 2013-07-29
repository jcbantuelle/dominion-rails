module Laboratory

  def starting_count(game)
    10
  end

  def cost
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play(game)
    game.current_turn.add_actions(1)
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(2)
  end

  def log(game, player)
    gets = '+1 action'
    Renderer.new.render 'game/log/play_card', { game: game, player: player, card: self, gets: gets, card_drawer: @card_drawer }
  end
end
