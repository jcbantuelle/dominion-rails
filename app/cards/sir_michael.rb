module SirMichael

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action, :attack, :knight]
  end

  def play(game, clone=false)
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        players.each do |player|
          discard_cards(game, player)
          reveal(game, player)
          trash_card(game, player)
          revealed_cards = player.player_cards.revealed
          CardDiscarder.new(player, revealed_cards).discard
          TurnActionHandler.wait_for_response(game)
        end
      end
    }
  end

  def discard_cards(game, player)
    hand = player.hand
    if hand.count <= 3
      @log_updater.custom_message(player, "#{hand.count} cards in hand", 'have')
    else
      discard_count = hand.count - 3
      action = TurnActionHandler.send_choose_cards_prompt(game, player, hand, "Choose #{discard_count} card(s) to discard:", discard_count, discard_count, 'discard')
      TurnActionHandler.process_player_response(game, player, action, self)
    end
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

  def process_action(game, game_player, action)
    if action.action == 'trash'
      card = PlayerCard.find action.response
      CardTrasher.new(game_player, [card]).trash
      trash_self(game) if card.knight?
    elsif action.action == 'discard'
      discarded_cards = PlayerCard.where(id: action.response.split)
      CardDiscarder.new(game_player, discarded_cards).discard('hand')
    end
  end

  def trash_self(game)
    card_to_trash = game.current_player.find_card_in_play('sir_michael')
    CardTrasher.new(game.current_player, [card_to_trash]).trash unless card_to_trash.nil?
  end

end
