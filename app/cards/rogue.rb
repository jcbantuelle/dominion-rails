class Rogue < Card

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
    game.current_turn.add_coins(2)
    @log_updater.get_from_card(game.current_player, '+$2')
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        trash = game.trash_cards_costing_between(6, 3)
        if trash.count == 0
          @log_updater.custom_message(nil, 'But there are no trashed cards to gain')
          game.current_turn.add_rogue
        elsif trash.count == 1
          gain_trash_on_deck(game, game.current_player, trash.first)
        else
          action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, trash, 'Choose a card to gain:', 1, 1, 'gain')
          TurnActionHandler.process_player_response(game, game.current_player, action, self)
        end
      end
    }
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        if game.current_turn.rogues > 0
          game.current_turn.remove_rogue
          players.each do |player|
            reveal(game, player)
            trash_card(game, player)
            TurnActionHandler.wait_for_response(game)
          end
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
      @log_updater.reveal(player, @revealed, 'deck')
      available_cards = @revealed.select{ |card|
        cost = card.calculated_cost(game, game.current_turn)[:coin]
        cost > 2 && cost < 7
      }
      if available_cards.count == 1
        CardTrasher.new(player, available_cards).trash
      elsif available_cards.count > 1
        action = TurnActionHandler.send_choose_cards_prompt(game, player, available_cards, 'Choose which card to trash:', 1, 1, 'trash')
        TurnActionHandler.process_player_response(game, player, action, self)
      end
    end
    revealed_cards = player.player_cards.revealed
    CardDiscarder.new(player, revealed_cards).discard
  end

  def process_action(game, game_player, action)
    if action.action == 'gain'
      gain_trash_on_deck(game, game_player, GameTrash.find(action.response))
    elsif action.action == 'trash'
      card = PlayerCard.find action.response
      CardTrasher.new(game_player, [card]).trash
    end
  end

  def gain_trash_on_deck(game, game_player, trash_card)
    card = PlayerCard.create(game_player: game_player, card: trash_card.card, state: 'discard')
    LogUpdater.new(game).gain(game_player, [card], 'trash')
    trash_card.destroy
  end

end
