module Militium

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
    Thread.new {
      players.each do |player|
        hand = player.hand
        if hand.count <= 3
          @log_updater.custom_message(player, "#{hand.count} cards in hand", 'have')
        else
          discard_count = hand.count - 3
          action = send_choose_cards_prompt(game, player, hand, "Choose #{discard_count} card(s) to discard:", discard_count, discard_count)
          process_player_response(game, player, action)
        end
      end
      ActiveRecord::Base.clear_active_connections!
    }
  end

  private

  def process_action(game, game_player, action)
    discarded_cards = PlayerCard.where(id: action.response.split)
    discarded_cards.update_all state: 'discard'
    LogUpdater.new(game).discard(game_player, discarded_cards, 'hand')
    update_player_hand(game, game_player.player)
  end

end
