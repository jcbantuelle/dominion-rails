module Moneylender

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

  def play(game, clone=false)
    if trash_copper(game)
      game.current_turn.add_coins(3)
      @log_updater.get_from_card(game.current_player, '+$3')
    end
  end

  def trash_copper(game)
    copper = game.current_player.find_card_in_hand('copper')
    CardTrasher.new(game.current_player, [copper]).trash('hand') unless copper.nil?
    copper.present?
  end
end
