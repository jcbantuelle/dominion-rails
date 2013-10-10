module Pillage

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
    pillage = game.current_player.find_card_in_play('pillage')
    CardTrasher.new(game.current_player, [pillage]).trash
    2.times do
      CardGainer.new(game, game.current_player, 'spoils').gain_card('discard')
    end
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        players.each do |player|
          hand = player.hand
          if hand.count > 4
            @log_updater.reveal(player, hand, 'hand')
            action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, hand, "Choose one of #{player.username}'s cards to discard:", 1, 1)
            TurnActionHandler.process_player_response(game, player, action, self)
          end
        end
      end
    }
  end

  def process_action(game, game_player, action)
    discarded_cards = PlayerCard.where(id: action.response)
    CardDiscarder.new(game_player, discarded_cards).discard('hand')
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end
end
