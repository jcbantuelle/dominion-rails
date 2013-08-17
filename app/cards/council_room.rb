module CouncilRoom

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

  def play(game)
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(4)
    game.current_turn.add_buys(1)

    game.game_players.each do |player|
      unless player.id == game.current_player.id
        CardDrawer.new(player).draw(1)
      end
    end
  end
end
