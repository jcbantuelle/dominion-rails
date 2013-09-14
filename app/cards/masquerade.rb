module Masquerade

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 3
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(2)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        pass_cards_left(game)
        trash_card(game)
      end
    }
  end

  def pass_cards_left(game)
    actions = []
    game.turn_ordered_players.each do |player|
      action = {player: player}
      action[:action] = TurnActionHandler.send_choose_cards_prompt(game, player, player.hand, "Choose a card to pass left:", 1, 1, 'pass') unless player.hand.count == 0
      actions << action
    end
    actions.each do |action|
      if action[:action].nil?
        LogUpdater.new(game).custom_message(action[:player], 'no cards to pass', 'have')
      else
        TurnActionHandler.process_player_response(game, action[:player], action[:action], self)
      end
    end
  end

  def trash_card(game)
    action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, game.current_player.hand, 'Choose up to 1 card to trash:', 0, 1, 'trash')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def process_action(game, game_player, action)
    if action.action == 'pass'
      pass_card(game, game_player, action)
    elsif action.action == 'trash'
      trash_card_from_hand(game, game_player, action)
    end
  end

  def pass_card(game, game_player, action)
    passed_card = PlayerCard.find action.response
    player_to_left = game.player_to_left(game_player)
    passed_card.update game_player_id: player_to_left.id
    LogUpdater.new(game).pass(game_player, player_to_left, passed_card)
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
    TurnActionHandler.refresh_game_area(game, player_to_left.player)
  end

  def trash_card_from_hand(game, game_player, action)
    unless action.response.empty?
      card = PlayerCard.find action.response
      CardTrasher.new(game_player, [card]).trash('hand')
    end
  end

end
