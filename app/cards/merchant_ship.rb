class MerchantShip < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action, :duration]
  end

  def play(game, clone=false)
    action(game, false)
  end

  def duration(game)
    action(game, true)
  end

  def action(game, duration)
    game.current_turn.add_coins(2)
    message = "+$2"
    message += " from #{self.card_html}" if duration
    @log_updater.get_from_card(game.current_player, message)
  end

end
