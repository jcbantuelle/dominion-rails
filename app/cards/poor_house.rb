module PoorHouse

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 1
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    coins = reveal_hand(game)
    coins = 0 if coins < 0
    game.current_turn.add_coins(coins)
    @log_updater.get_from_card(game.current_player, "+$#{coins}")
  end

  private

  def reveal_hand(game)
    hand = game.current_player.player_cards.hand
    @log_updater.reveal(game.current_player, hand, 'hand')
    4 - hand.select{ |c| c.treasure? }.count
  end

end
