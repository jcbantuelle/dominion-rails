module Fortress

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(1)
    game.current_turn.add_actions(2)
    @log_updater.get_from_card(game.current_player, '+2 actions')
  end

  def trash_reaction(game, player)
    fortress = game.game_trashes.select{ |card| card.name == 'fortress' }.first
    PlayerCard.create game_player: player, card: fortress.card, state: 'hand'
    LogUpdater.new(game).custom_message(player, "#{fortress.card.card_html} in hand from trash".html_safe, 'put')
    fortress.destroy
  end

end
