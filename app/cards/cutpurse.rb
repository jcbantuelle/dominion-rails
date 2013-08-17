module Cutpurse

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game)
    game.current_turn.add_coins(2)
    @log_updater.get_from_card(game.current_player, '+$2')

    copper = Card.by_name 'copper'
    game.game_players.each do |player|
      unless player.id == game.current_player.id
        copper_in_hand = player.hand.select{|card| card.card_id == copper.id }
        if copper_in_hand.count > 0
          copper_in_hand.first.discard
          @log_updater.discard(player, [copper_in_hand.first])
        else
          @log_updater.reveal(player, player.hand, 'hand')
        end
      end
    end
  end

end
