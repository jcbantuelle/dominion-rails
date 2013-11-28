class Knight < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action, :attack, :knight]
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        players.each do |player|
          knight_attack(game, player)
        end
      end
    }
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
        CardTrasher.new(player, available_cards).trash
        trash_self(game) if trashed_card.knight?
      elsif available_cards.count > 1
        action = TurnActionHandler.send_choose_cards_prompt(game, player, available_cards, 'Choose which card to trash:', 1, 1, 'trash')
        TurnActionHandler.process_player_response(game, player, action, self)
      end
    end
  end

  def knight_trash(game, game_player, action)
    card = PlayerCard.find action.response
    CardTrasher.new(game_player, [card]).trash
    trash_self(game) if card.knight?
  end

  def knight_attack(game, player)
    reveal(game, player)
    trash_card(game, player)
    revealed_cards = player.player_cards.revealed
    CardDiscarder.new(player, revealed_cards).discard
    TurnActionHandler.wait_for_response(game)
  end

  def reveal(game, player)
    @revealed = []
    reveal_cards(game, player)
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 2
  end

  def reveal_finished?(game, player)
    @revealed.count == 2 || player.discard.count == 0
  end

  def process_action(game, game_player, action)
    knight_trash(game, game_player, action) if action.action == 'trash'
  end

end
