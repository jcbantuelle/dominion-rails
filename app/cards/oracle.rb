module Oracle

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 3
    }
  end

  def type
    [:action, :attack]
  end

  def play(game, clone=false)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        reveal(game, game.current_player)
        discard_or_keep(game, game.current_player) unless @revealed.empty?
        CardDrawer.new(game.current_player).draw(2)
        ActiveRecord::Base.connection.clear_query_cache
        TurnActionHandler.refresh_game_area(game, game.current_player.player)
      end
    }
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        players.each do |player|
          reveal(game, player)
          discard_or_keep(game, player) unless @revealed.empty?
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, player.player)
        end
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'choose'
      if action.response == 'discard'
        CardDiscarder.new(game_player, @revealed).discard
      elsif action.response == 'keep'
        action = TurnActionHandler.send_order_cards_prompt(game, game_player, @revealed, 'Choose order to put cards on deck (1st is top of deck)', 'reorder')
        TurnActionHandler.process_player_response(game, game_player, action, self)
      end
    elsif action.action == 'reorder'
      action.response.split.reverse.each do |card_id|
        card = PlayerCard.find card_id
        put_card_on_deck(game, game_player, card, false)
      end
    end
  end

  def discard_or_keep(game, player)
    options = [
      { text: 'Discard', value: 'discard' },
      { text: 'Keep', value: 'keep' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Choose whether to Discard or Keep revealed cards:'.html_safe, 1, 1, 'choose')
    TurnActionHandler.process_player_response(game, player, action, self)
  end

  def reveal(game, player)
    @revealed = []
    reveal_cards(game, player)
    @log_updater.reveal(player, @revealed, 'deck')
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 2
  end

  def reveal_finished?(game, player)
    @revealed.count == 2 || player.discard.count == 0
  end

end
