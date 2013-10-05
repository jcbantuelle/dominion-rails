module SirDestry

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action, :attack, :knight]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(2)
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        players.each do |player|
          reveal(game, player)
          trash_card(game, player)
          TurnActionHandler.wait_for_response(game)
        end
      end
    }
  end

  def reveal(game, player)
    @revealed = []
    reveal_cards(game, player)
    player.discard_revealed
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 2
  end

  def reveal_finished?(game, player)
    @revealed.count == 2 || player.discard.count == 0
  end

  def trash_card(game, player)
    if @revealed.count == 0
      @log_updater.custom_message(nil, 'But there are no cards in deck')
    else
      @log_updater.reveal(player, @revealed, 'deck', false)
      available_cards = @revealed.select{ |card|
        cost = card.calculated_cost(game, game.current_turn)[:coin]
        cost > 2 && cost < 7
      }
      if available_cards.count == 1
        trashed_card = available_cards.first
        CardTrasher.new(player, available_cards).trash(nil, true)
        trash_self(game) if trashed_card.knight?
      elsif available_cards.count > 1
        action = TurnActionHandler.send_choose_cards_prompt(game, player, available_cards, 'Choose which card to trash:', 1, 1, 'trash')
        TurnActionHandler.process_player_response(game, player, action, self)
      end
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'trash'
      card = PlayerCard.find action.response
      CardTrasher.new(game_player, [card]).trash(nil, true)
      trash_self(game) if card.knight?
    end
  end

  def trash_self(game)
    card_to_trash = game.current_player.find_card_in_play('sir_destry')
    CardTrasher.new(game.current_player, [card_to_trash]).trash unless card_to_trash.nil?
  end

end
