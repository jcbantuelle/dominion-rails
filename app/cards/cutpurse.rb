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
    [:action, :attack]
  end

  def play(game, clone=false)
    game.current_turn.add_coins(2)
    @log_updater.get_from_card(game.current_player, '+$2')
  end

  def attack(game, players)
    players.each do |player|
      copper = player.find_card_in_hand('copper')
      if copper.nil?
        @log_updater.reveal(player, player.hand, 'hand')
      else
        copper.discard
        @log_updater.discard(player, [copper])
      end
    end
  end

end
