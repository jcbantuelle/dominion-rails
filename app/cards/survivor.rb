module Survivor

  def cost(game, turn)
    {
      coin: 0
    }
  end

  def type
    [:action, :ruin]
  end

  def play(game, clone=false)
    reveal(game)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        keep_or_discard(game)
      end
    }
  end

  def keep_or_discard(game)
    options = [
      { text: 'Discard', value: 'discard' },
      { text: 'Replace', value: 'replace' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, "Discard or Replace on Deck?".html_safe, 1, 1, 'choose')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def process_action(game, game_player, action)
    if action.action == 'choose'
      if action.response == 'discard'
        CardDiscarder.new(game_player, @revealed).discard
      elsif action.response == 'replace'
        action = TurnActionHandler.send_order_cards_prompt(game, game_player, @revealed, 'Choose order to put cards on deck (1st is top of deck)', 'replace')
        TurnActionHandler.process_player_response(game, game_player, action, self)
      end
    elsif action.action == 'replace'
      action.response.split.reverse.each do |card_id|
        card = PlayerCard.find card_id
        put_card_on_deck(game, game_player, card, false)
      end
    end
  end

  def reveal(game)
    @revealed = []
    reveal_cards(game, game.current_player)
    @log_updater.look(game.current_player, @revealed, 'deck')
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 2
  end

  def discard_revealed(game)
    game.current_player.discard_revealed
  end

  def reveal_finished?(game, player)
    @revealed.count == 2 || game.current_player.discard.count == 0
  end

end
