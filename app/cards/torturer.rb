module Torturer

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action, :attack]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(3)
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        players.each do |player|
          choose_attack(game, player)
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, player.player)
        end
      end
    }
  end

  def choose_attack(game, player)
    options = [
      { text: 'Discard two cards', value: 'discard' },
      { text: 'Gain a curse', value: 'curse' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(game, player, options, 'Choose one:', 1, 1, 'pick')
    TurnActionHandler.process_player_response(game, player, action, self)
  end

  def process_action(game, game_player, action)
    if action.action == 'pick'
      pick_attack(game, game_player, action)
    elsif action.action == 'discard'
      discard_cards(game, game_player, action)
    end
  end

  def pick_attack(game, game_player, action)
    if action.response == 'curse'
      give_card_to_player(game, game_player, 'curse', 'hand')
    elsif action.response == 'discard'
      hand = game_player.hand
      if hand.count < 3
        hand.update_all state: 'discard'
        LogUpdater.new(game).discard(game_player, hand, 'hand')
      else
        action = TurnActionHandler.send_choose_cards_prompt(game, game_player, hand, "Choose 2 cards to discard:", 2, 2, 'discard')
        TurnActionHandler.process_player_response(game, game_player, action, self)
      end
    end
  end

  def discard_cards(game, game_player, action)
    discarded_cards = PlayerCard.where(id: action.response.split)
    discarded_cards.update_all state: 'discard'
    LogUpdater.new(game).discard(game_player, discarded_cards, 'hand')
  end

end
