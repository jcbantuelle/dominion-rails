module Wharf

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 5
    }
  end

  def type
    [:action, :duration]
  end

  def play(game)
    action(game, false)
  end

  def duration(game)
    action(game, true)
  end

  def action(game, duration)
    draw_cards(game, duration)
    add_buys(game, duration)
  end

  private

  def draw_cards(game, duration)
    card_drawer = CardDrawer.new(game.current_player)
    duration ? card_drawer.draw_duration(2, self) : card_drawer.draw(2)
  end

  def add_buys(game, duration)
    game.current_turn.add_buys(1)
    message = "+1 buy"
    message += " from #{self.card_html}" if duration
    @log_updater.get_from_card(game.current_player, message)
  end

end
