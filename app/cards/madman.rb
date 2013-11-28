class Madman < Card

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
    [:action]
  end

  def play(game, clone=false)
    game.current_turn.add_actions(2)
    LogUpdater.new(game).get_from_card(game.current_player, '+2 actions')
    madman = game.current_player.find_card_in_play('madman')
    unless madman.nil?
      madman.destroy
      game.game_cards.by_card_id(id).first.add_to_pile(1)
      LogUpdater.new(game).return_to_supply(game.current_player, [self])

      @card_drawer = CardDrawer.new(game.current_player)
      @card_drawer.draw(game.current_player.hand.count)
    end
  end

end
