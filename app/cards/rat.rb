module Rat

  def starting_count(game)
    20
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
    CardDrawer.new(game.current_player).draw(1)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')
    rats = GameCard.by_game_id_and_card_name(game.id, 'rats').first
    CardGainer.new(game, game.current_player, rats.id).gain_card('discard')

    available_cards = game.current_player.hand.select{ |card| card.name != 'rats' }
    if available_cards.count == 0
      @log_updater.reveal(game.current_player, game.current_player.hand, 'hand')
    elsif available_cards.count == 1
      CardTrasher.new(game.current_player, available_cards).trash('hand')
    else
      @play_thread = Thread.new {
        action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, available_cards, 'Choose a card to trash:', 1, 1)
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
        TurnActionHandler.refresh_game_area(game, game.current_player.player)
        ActiveRecord::Base.clear_active_connections!
      }
    end
  end

  def process_action(game, game_player, action)
    trashed_card = PlayerCard.find action.response
    CardTrasher.new(game_player, [trashed_card]).trash('hand')
  end

  def trash_reaction(game, player)
    CardDrawer.new(player).draw(1, true, self)
  end

end
