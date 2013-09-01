module Spoil

  def starting_count(game)
    15
  end

  def cost(game)
    {
      coin: 0
    }
  end

  def allowed?(game)
    false
  end

  def type
    [:treasure]
  end

  def play(game, clone=false)
    game.current_turn.add_coins(3)
    game.current_player.find_card_in_play('spoils').destroy
    game.game_cards.by_card_id(id).first.add_to_pile(1)
    LogUpdater.new(game).return_to_supply(game.current_player, [self])
  end

end
