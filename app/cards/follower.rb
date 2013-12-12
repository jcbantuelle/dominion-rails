class Follower < Card

  def starting_count(game)
    1
  end

  def cost(game, turn)
    {
      coin: 0
    }
  end

  def type
    [:action, :attack]
  end

  def play(game, clone=false)
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(2)
    give_card_to_player(game, game.current_player, 'estate', 'discard')
  end

  def attack(game, players)
    players.each do |player|
      give_card_to_player(game, player, 'curse', 'discard')
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

  def process_action(game, game_player, action)
    discarded_cards = PlayerCard.where(id: action.response.split)
    CardDiscarder.new(game_player, discarded_cards).discard('hand')
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end
end
