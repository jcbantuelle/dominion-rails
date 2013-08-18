module Monument

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game)
    game.current_player.add_victory_tokens(1)
    game.current_turn.add_coins(2)
    @log_updater.get_from_card(game.current_player, "+$2 and +1 &nabla;".html_safe)
  end

end
