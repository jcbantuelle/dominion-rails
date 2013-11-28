class DameAnna < Knight

  def play(game, clone=false)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, game.current_player.hand, 'Choose up to 2 cards to trash:', 2, 0, 'trash_hand')
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'trash'
      knight_trash(game, game_player, action)
    elsif action.action == 'trash_hand'
      trashed_cards = PlayerCard.where(id: action.response.split)
      CardTrasher.new(game_player, trashed_cards).trash('hand')
    end
  end

  def trash_self(game)
    card_to_trash = game.current_player.find_card_in_play('dame_anna')
    CardTrasher.new(game.current_player, [card_to_trash]).trash unless card_to_trash.nil?
  end

end
