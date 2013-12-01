class Haggler < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    game.current_turn.add_coins(2)
    game.current_turn.add_haggler
    @log_updater.get_from_card(game.current_player, '+$2')
  end

end
