class Loan < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 3
    }
  end

  def type
    [:treasure]
  end

  def play(game, clone=false)
    game.current_turn.add_coins(1)
    reveal(game)
    process_treasure(game)
    discard_revealed(game)
  end

  def process_treasure(game)
    if @treasures.empty?
      LogUpdater.new(game).custom_message(nil, 'But no treasure was revealed')
    else
      options = [
        { text: 'Discard', value: 'discard' },
        { text: 'Trash', value: 'trash' }
      ]
      action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, "Discard or Trash #{@treasures.first.card.card_html}?".html_safe, 1, 1, 'choose')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'choose'
      if action.response == 'discard'
        CardDiscarder.new(game_player, @treasures).discard
      elsif action.response == 'trash'
        CardTrasher.new(game_player, @treasures).trash
      end
    end
  end

  def reveal(game)
    @revealed = []
    @treasures = []

    reveal_cards(game, game.current_player)
    @log_updater.reveal(game.current_player, @revealed, 'deck')
  end

  def process_revealed_card(card)
    if card.treasure?
      @treasures << card
      card.update_attribute :state, 'hand'
    else
      card.update_attribute :state, 'revealed'
    end
    @treasures.count == 1
  end

  def discard_revealed(game)
    revealed_cards = game.current_player.player_cards.revealed
    CardDiscarder.new(game.current_player, revealed_cards).discard
  end

  def reveal_finished?(game, player)
    @treasures.count == 1 || game.current_player.empty_discard?
  end

end
