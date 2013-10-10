module DameAnna

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action, :attack, :knight]
  end

  def play(game, clone=false)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, game.current_player.hand, 'Choose up to 2 cards to trash:', 2, 0, 'trash_hand')
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
    }
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        players.each do |player|
          reveal(game, player)
          trash_card(game, player)
          revealed_cards = player.player_cards.revealed
          CardDiscarder.new(player, revealed_cards).discard
          TurnActionHandler.wait_for_response(game)
        end
      end
    }
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
    elsif action.action == 'trash_hand'
      trashed_cards = PlayerCard.where(id: action.response.split)
      CardTrasher.new(game_player, trashed_cards).trash('hand')
    end
  end

  def trash_self(game)
    card_to_trash = game.current_player.find_card_in_play('dame_anna')
    CardTrasher.new(game.current_player, [card_to_trash]).trash unless card_to_trash.nil?
  end

end
