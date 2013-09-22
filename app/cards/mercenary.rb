module Mercenary

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 0
    }
  end

  def allowed?(game)
    false
  end

  def type
    [:action, :attack]
  end

  def play(game, clone=false)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        options = [
          { text: 'Yes', value: 'yes' },
          { text: 'No', value: 'no' }
        ]
        hand = game.current_player.hand
        if hand.count == 0
          @log_updater.custom_message(game.current_player, 'nothing to trash', 'have')
        elsif hand.count == 1
          action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, "Trash #{hand.first.card.card_html}?".html_safe, 1, 1, 'trash_one')
          TurnActionHandler.process_player_response(game, game.current_player, action, self)
        else
          action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, 'Trash 2 cards?', 1, 1, 'trash_two')
          TurnActionHandler.process_player_response(game, game.current_player, action, self)
        end
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'discard'
      discarded_cards = PlayerCard.where(id: action.response.split)
      discarded_cards.update_all state: 'discard'
      LogUpdater.new(game).discard(game_player, discarded_cards, 'hand')
    elsif action.action == 'trash_one'
      CardTrasher.new(game_player, game_player.hand).trash('hand')
    elsif action.action == 'trash_two'
      if action.response == 'yes'
        game.current_turn.add_mercenary
        if game_player.hand.count == 2
          CardTrasher.new(game_player, game_player.hand).trash('hand')
        else
          action = TurnActionHandler.send_choose_cards_prompt(game, game_player, game_player.hand, 'Choose 2 cards to trash:', 2, 2, 'trash')
          TurnActionHandler.process_player_response(game, game_player, action, self)
        end
        game.current_turn.add_coins(2)
        CardDrawer.new(game_player).draw(2)
        LogUpdater.new(game).get_from_card(game_player, '+$2')
      end
    elsif action.action == 'trash'
      trashed_cards = PlayerCard.where(id: action.response.split)
      CardTrasher.new(game_player, trashed_cards).trash('hand')
    end
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

  def attack(game, players)
    if game.current_turn.mercenaries > 0
      game.current_turn.remove_mercenary
      @attack_thread = Thread.new {
        ActiveRecord::Base.connection_pool.with_connection do
          players.each do |player|
            hand = player.hand
            if hand.count <= 3
              @log_updater.custom_message(player, "#{hand.count} cards in hand", 'have')
            else
              discard_count = hand.count - 3
              action = TurnActionHandler.send_choose_cards_prompt(game, player, hand, "Choose #{discard_count} card(s) to discard:", discard_count, discard_count, 'discard')
              TurnActionHandler.process_player_response(game, player, action, self)
            end
          end
        end
      }
    end
  end

end
