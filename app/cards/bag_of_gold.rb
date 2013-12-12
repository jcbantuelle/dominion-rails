class BagOfGold < Card

  def starting_count(game)
    1
  end

  def cost(game, turn)
    {
      coin: 0
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')
    give_card_to_player(game, game.current_player, 'gold', 'deck')
  end

end
