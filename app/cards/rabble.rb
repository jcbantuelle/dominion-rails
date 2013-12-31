class Rabble < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action, :attack]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(3)
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        players.each do |player|
          reveal(game, player)
          CardDiscarder.new(player, @discard).discard unless @discard.empty?
          keep_cards(game, player) unless @keep.empty?
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, player.player)
        end
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'reorder'
      action.response.split.reverse.each do |card_id|
        card = PlayerCard.find card_id
        put_card_on_deck(game, game_player, card, false)
      end
    end
  end

  def keep_cards(game, player)
    if @keep.count == 1
      put_card_on_deck(game, player, @keep.first, false)
    else
      action = TurnActionHandler.send_order_cards_prompt(game, player, @keep, 'Choose order to put cards on deck (1st is top of deck)', 'reorder')
      TurnActionHandler.process_player_response(game, player, action, self)
    end
  end

  def reveal(game, player)
    @revealed = []
    @keep = []
    @discard = []
    reveal_cards(game, player)
    @log_updater.reveal(player, @revealed, 'deck')
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    if card.action? || card.treasure?
      @discard << card
    else
      @keep << card
    end
    @revealed.count == 3
  end

  def reveal_finished?(game, player)
    @revealed.count == 3 || player.discard.count == 0
  end

end
