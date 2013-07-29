module Village

  def starting_count(game)
    10
  end

  def cost
    {
      coin: 3
    }
  end

  def type
    [:action]
  end

  def play(game)
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(1)
    game.current_turn.add_actions(2)
  end

  def log(game, player)
    get_text = '+2 actions'
    render_play_card game, player, get_text, @card_drawer
  end
end
