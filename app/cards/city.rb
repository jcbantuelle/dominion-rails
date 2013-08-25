module City

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
    game.current_turn.add_actions(2)
    @message = '+2 actions'
    @cards = 1

    process_empty_piles(game)

    card_drawer = CardDrawer.new(game.current_player)
    card_drawer.draw(@cards)

    @log_updater.get_from_card(game.current_player, @message)
  end

  def process_empty_piles(game)
    empty_piles = game.game_cards.empty_piles.count

    two_empty_piles(game) if empty_piles > 1
    one_empty_pile if empty_piles > 0
  end

  def two_empty_piles(game)
    game.current_turn.add_coins(1)
    game.current_turn.add_buys(1)
    @message += ', +1 buy, and +$1'
  end

  def one_empty_pile
    @cards = 2
  end

end
