class SirMichael < Knight

  def play(game, clone=false)
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        players.each do |player|
          discard_cards(game, player)
          knight_attack(game, player)
        end
      end
    }
  end

  def discard_cards(game, player)
    hand = player.hand
    if hand.count <= 3
      @log_updater.custom_message(player, "#{hand.count} cards in hand", 'have')
    else
      discard_count = hand.count - 3
      action = TurnActionHandler.send_choose_cards_prompt(game, player, hand, "Choose #{discard_count} card(s) to discard:", discard_count, discard_count, 'discard')
      TurnActionHandler.process_player_response(game, player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'trash'
      knight_trash(game, game_player, action)
    elsif action.action == 'discard'
      discarded_cards = PlayerCard.where(id: action.response.split)
      CardDiscarder.new(game_player, discarded_cards).discard('hand')
    end
  end

  def trash_self(game)
    card_to_trash = game.current_player.find_card_in_play('sir_michael')
    CardTrasher.new(game.current_player, [card_to_trash]).trash unless card_to_trash.nil?
  end

end
