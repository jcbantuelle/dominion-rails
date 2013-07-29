module Gold

  def starting_count(game)
    30
  end

  def cost
    {
      coin: 6
    }
  end

  def type
    [:treasure]
  end

  def play(game)
    game.current_turn.add_coins(3)
  end

  def log(game, player)
    Renderer.new.render 'game/log/play_card', { game: game, player: player, card: self }
  end
end
