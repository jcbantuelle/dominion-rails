class Apothecary < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 2,
      potion: 1
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(1)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')
    reveal(game)
    add_treasures_to_hand(game)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        replace_remaining_cards(game)
      end
    }
  end

  def process_action(game, game_player, action)
    action.response.split.reverse.each do |card_id|
      card = PlayerCard.find card_id
      put_card_on_deck(game, game_player, card, true)
    end
  end

  private

  def add_treasures_to_hand(game)
    treasures = []
    @remaining_cards = []
    @revealed.each do |card|
      if card.name == 'copper' || card.name == 'potion'
        treasures << card
        card.update state: 'hand'
      else
        @remaining_cards << card
      end
    end
    @log_updater.put(game.current_player, treasures, 'hand', false)
  end

  def replace_remaining_cards(game)
    if @remaining_cards.count > 0
      action = TurnActionHandler.send_order_cards_prompt(game, game.current_player, @remaining_cards, 'Choose order to put cards on deck (1st is top of deck)')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def reveal(game)
    @revealed = []
    reveal_cards(game, game.current_player)
    @log_updater.reveal(game.current_player, @revealed, 'deck')
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 4
  end

  def reveal_finished?(game, player)
    @revealed.count == 4 || game.current_player.discard.count == 0
  end

end
