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
    get_text = '+1 action'
    render_play_card game, player, get_text, @card_drawer
  end
end
