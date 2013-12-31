class Watchtower < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 3
    }
  end

  def type
    [:action, :reaction]
  end

  def play(game, clone=false)
    draw_to_six(game)
  end

  def process_action(game, game_player, action)
    if action.action == 'reveal'
      if action.response == 'yes'
        reveal_watchtower(game, game_player, action)
      end
    elsif action.action == 'choose'
      choose_action(game, game_player, action)
    end
  end

  def reaction(game, game_player, card)
    if game_player.id == game.current_player.id && PlayerCard.exists?(card.id)
      gained_card = PlayerCard.find(card.id)
      if gained_card.state == 'discard'
        watchtower = Card.by_name('watchtower')
        options = [
          { text: 'Yes', value: 'yes' },
          { text: 'No', value: 'no' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game_player, options, "Reveal #{watchtower.card_html}?".html_safe, 1, 1, 'reveal')
        action.update_attribute :affected_id, gained_card.id
        TurnActionHandler.process_player_response(game, game_player, action, self)
      end
    end
  end

  def draw_to_six(game)
    cards_to_draw = 6 - game.current_player.hand.count
    CardDrawer.new(game.current_player).draw(cards_to_draw) if cards_to_draw > 0
  end

  def reveal_watchtower(game, game_player, action)
    watchtower = game_player.find_card_in_hand('watchtower')
    LogUpdater.new(game).reveal(game_player, [watchtower], 'hand')
    gained_card = PlayerCard.find(action.affected_id)
    options = [
      { text: 'Trash', value: 'trash' },
      { text: 'Deck', value: 'deck' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(game, game_player, options, "Trash #{gained_card.card.card_html} or Put on Top of Deck?".html_safe, 1, 1, 'choose')
    action.update_attribute :affected_id, gained_card.id
    TurnActionHandler.process_player_response(game, game_player, action, self)
  end

  def choose_action(game, game_player, action)
    card = PlayerCard.find action.affected_id
    if action.response == 'trash'
      CardTrasher.new(game_player, [card]).trash('hand')
    elsif action.response == 'deck'
      put_card_on_deck(game, game_player, card, true)
    end
  end

end
