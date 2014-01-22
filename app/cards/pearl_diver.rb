class PearlDiver < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 2
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    card_drawer = CardDrawer.new(game.current_player)
    card_drawer.draw(1)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')

    game.current_player.shuffle_discard_into_deck if game.current_player.deck.empty?
    @bottom_card = game.current_player.deck.reverse.first
    if @bottom_card.nil?
      @log_updater.custom_message(nil, 'But there are no cards in deck')
    else
      @log_updater.look(game.current_player, [@bottom_card])
      options = [
        { text: 'Yes', value: 'yes' },
        { text: 'No', value: 'no' }
      ]
      action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, "Put #{@bottom_card.card.card_html} on top?".html_safe, 1, 1)
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    game_player.put_card_on_deck(@bottom_card) if action.response == 'yes'
  end

end
