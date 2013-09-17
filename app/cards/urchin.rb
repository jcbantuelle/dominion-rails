module Urchin

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
    CardDrawer.new(game.current_player).draw(1)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        players.each do |player|
          hand = player.hand
          if hand.count <= 4
            @log_updater.custom_message(player, "#{hand.count} cards in hand", 'have')
          else
            discard_count = hand.count - 4
            action = TurnActionHandler.send_choose_cards_prompt(game, player, hand, "Choose #{discard_count} card(s) to discard:", discard_count, discard_count, 'discard')
            TurnActionHandler.process_player_response(game, player, action, self)
          end
        end
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'discard'
      discarded_cards = PlayerCard.where(id: action.response.split)
      discarded_cards.update_all state: 'discard'
      LogUpdater.new(game).discard(game_player, discarded_cards, 'hand')
    elsif action.action == 'trash'
      if action.response == 'yes'
        urchin = game_player.find_card_in_play('urchin')
        CardTrasher.new(game_player, [urchin]).trash('play')
        give_card_to_player(game, game_player, 'mercenary', 'discard')
      end
    end
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

  def reaction(game, game_player)
    @reaction_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        options = [
          { text: 'Yes', value: 'yes' },
          { text: 'No', value: 'no' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, game_player, options, "Trash #{card_html}?".html_safe, 1, 1, 'trash')
        TurnActionHandler.process_player_response(game, game_player, action, self)
      end
    }
  end

end
