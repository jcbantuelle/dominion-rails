module Silver

  def starting_count(game)
    40
  end

  def cost
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
    Renderer.new.render 'game/log/play_card', { game: game, player: player, card: self }
  end
end
