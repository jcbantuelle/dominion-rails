class Margrave < Card

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
    game.current_turn.add_buys(1)
    @log_updater.get_from_card(game.current_player, '+1 buy')
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        players.each do |player|
          CardDrawer.new(player).draw(1)
          hand = player.hand
          if hand.count <= 3
            @log_updater.custom_message(player, "#{hand.count} cards in hand", 'have')
          else
            discard_count = hand.count - 3
            action = TurnActionHandler.send_choose_cards_prompt(game, player, hand, "Choose #{discard_count} card(s) to discard:", discard_count, discard_count)
            TurnActionHandler.process_player_response(game, player, action, self)
          end
        end
      end
    }
  end

  def process_action(game, game_player, action)
    discarded_cards = PlayerCard.where(id: action.response.split)
    CardDiscarder.new(game_player, discarded_cards).discard('hand')
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

end
