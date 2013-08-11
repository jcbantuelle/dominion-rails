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
    locals = {
      get_text: '+1 action, +1 buy, and +$1',
      card_drawer: @card_drawer
    }
    render_play_card game, player, locals
  end
end
