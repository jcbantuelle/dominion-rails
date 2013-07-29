module Market

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
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(1)
    game.current_turn.add_actions(1)
    game.current_turn.add_buys(1)
    game.current_turn.add_coins(1)
  end

  def log(game, player)
    get_text = '+1 action, +1 buy, and +$1'
    Renderer.new.render 'game/log/play_card', { game: game, player: player, card: self, get_text: get_text, card_drawer: @card_drawer }
  end
end
