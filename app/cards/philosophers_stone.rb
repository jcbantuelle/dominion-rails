module PhilosophersStone

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 3,
      potion: 1
    }
  end

  def type
    [:treasure]
  end

  def play(game)
    card_count = deck_count(game)
    coins = card_count / 5
    game.current_turn.add_coins(coins)
    @log_updater.get_from_card(game.current_player, "+$#{coins} (#{card_count} cards)")
  end

  def deck_count(game)
    game.current_player.deck.count + game.current_player.discard.count
  end

end
