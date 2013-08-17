module Silver

  def starting_count(game)
    40
  end

  def cost(game)
    {
      coin: 3
    }
  end

  def type
    [:treasure]
  end

  def play(game)
    game.current_turn.add_coins(2)
  end

  def log(game, player)
    render_play_card game, player
  end
end
