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

  def play(game)
    if trash_copper(game)
      game.current_turn.add_coins(3)
      @log_updater.get_from_card(game.current_player, '+$3')
    end
  end

  def trash_copper(game)
    copper = game.current_player.find_card_in_hand('copper')
    unless copper.nil?
      CardTrasher.new(copper).trash
    end
    copper.present?
  end
end
