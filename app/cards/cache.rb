class Cache < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:treasure]
  end

  def play(game, clone=false)
    game.current_turn.add_coins(3)
  end

  def gain_event(game, player, event)
    card_gainer = CardGainer.new game, player, 'copper'
    2.times do
      card_gainer.gain_card('discard')
    end
  end

end
