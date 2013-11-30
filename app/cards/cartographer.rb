class Cartographer < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(1)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        reveal(game)
        discard_cards(game)
        replace_remaining_cards(game) unless @remaining.empty?
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'discard'
      @remaining = []
      @discarded = []
      discard_ids = action.response.split
      @revealed.each do |card|
        if discard_ids.include?(card.id.to_s)
          @discarded << card
        else
          @remaining << card
        end
      end
      CardDiscarder.new(game_player, @discarded).discard
    elsif action.action == 'reorder'
      action.response.split.reverse.each do |card_id|
        card = PlayerCard.find card_id
        put_card_on_deck(game, game_player, card, false)
      end
    end
  end

  private

  def discard_cards(game)
    action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, @revealed, 'Choose any number of cards to discard:', 0, 0, 'discard')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def replace_remaining_cards(game)
    action = TurnActionHandler.send_order_cards_prompt(game, game.current_player, @remaining, 'Choose order to put cards on deck (1st is top of deck)', 'reorder')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def reveal(game)
    @revealed = []
    reveal_cards(game, game.current_player)
    @log_updater.look(game.current_player, @revealed, 'deck')
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 4
  end

  def reveal_finished?(game, player)
    @revealed.count == 4 || game.current_player.discard.count == 0
  end

end
