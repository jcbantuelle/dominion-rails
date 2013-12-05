class WalledVillage < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(1)
    game.current_turn.add_actions(2)
    @log_updater.get_from_card(game.current_player, '+2 actions')
  end

  def discard_reaction(game, game_player, event, player_card)
    if event == :cleanup
      unless game_player.in_play.select(&:action?).count > 2
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
