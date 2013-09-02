module Library

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

  def play(game, clone=false)
    @play_thread = Thread.new {
      draw_cards(game) unless game.current_player.hand.count >= 7
      ActiveRecord::Base.clear_active_connections!
    }
  end

  def process_action(game, game_player, action)
    if action.response == 'yes'
      @drawn_card.update state: 'revealed'
      @log_updater.custom_message(game_player, "aside #{@drawn_card.card.card_html}".html_safe, 'set')
    end
  end

  private

  def draw_cards(game)
    card_drawer = CardDrawer.new(game.current_player)
    while(game.current_player.hand.count < 7 && cards_left(game)) do
      card_drawer.draw(1)
      @drawn_card = card_drawer.drawn_cards.first
      card_drawer.drawn_cards = []
      set_aside_action(game) if @drawn_card.action?
      TurnActionHandler.wait_for_response(game)
    end
    game.current_player.discard_revealed
    TurnActionHandler.refresh_game_area(game, game.current_player.player)
  end

  def cards_left(game)
    game.current_player.deck.count > 0 || game.current_player.discard.count > 0
  end

  def set_aside_action(game)
    options = [
      { text: 'Yes', value: 'yes' },
      { text: 'No', value: 'no' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, "Set aside #{@drawn_card.card.card_html}?".html_safe, 1, 1)
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

end
