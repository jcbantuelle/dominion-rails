module WanderingMinstrel

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
    @log_updater.get_from_card(game.current_player, '+2 action')
    reveal(game)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        replace_actions(game)
      end
    }
  end

  def process_action(game, game_player, action)
    action.response.split.reverse.each do |card_id|
      card = PlayerCard.find card_id
      put_card_on_deck(game, game_player, card, false)
    end
    discard_revealed(game.current_player)
  end

  private

  def replace_actions(game)
    actions = @revealed.select(&:action?)
    if actions.count == 0
      discard_revealed(game.current_player)
    elsif actions.count == 1
      put_card_on_deck(game, game.current_player, actions.first, false)
      discard_revealed(game.current_player)
    elsif actions.count > 1
      action = TurnActionHandler.send_order_cards_prompt(game, game.current_player, actions, 'Choose order to put cards on deck (1st is top of deck)')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def reveal(game)
    @revealed = []
    reveal_cards(game, game.current_player)
    @log_updater.reveal(game.current_player, @revealed, 'deck')
  end

  def discard_revealed(player)
    revealed_cards = player.player_cards.revealed
    CardDiscarder.new(player, revealed_cards).discard
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 3
  end

  def reveal_finished?(game, player)
    @revealed.count == 3 || game.current_player.discard.count == 0
  end

end
