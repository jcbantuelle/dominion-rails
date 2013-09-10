module BanditCamp

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(1)
    game.current_turn.add_actions(2)

    CardGainer.new(game, game.current_player, 'spoils').gain_card('discard')
  end

end
