class Alchemist < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 3,
      potion: 1
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(2)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')
  end

  def discard_reaction(game, game_player, event, player_card)
    if event == :cleanup
      unless game_player.find_card_in_play('potion').nil?
        @player_card = player_card
        options = [
          { text: 'Yes', value: 'yes' },
          { text: 'No', value: 'no' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, "Return #{player_card.card.card_html} to top of deck?".html_safe, 1, 1, 'deck')
        TurnActionHandler.process_player_response(game, game_player, action, self)
      end
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'deck' && action.response == 'yes'
      put_card_on_deck(game, game_player, @player_card, true)
    end
  end

end
