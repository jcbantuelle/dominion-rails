module Copper

  def starting_count(game)
    60
  end

  def cost
    {
      coin: 0
    }
  end

  def type
    [:treasure]
  end

  def play(game)
    game.current_turn.add_coins(1)
  end

  def log(game, player)
    Renderer.new.render 'game/log/play_card', { game: game, player: player, card: self }
  end
end
