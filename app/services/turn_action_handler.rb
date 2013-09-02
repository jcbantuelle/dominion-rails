class TurnActionHandler

  extend Json::Game

  def self.send_choose_cards_prompt(game, game_player, cards, message, maximum=0, minimum=0, action_type=nil)
    action = TurnAction.create game: game, game_player: game_player, action: action_type
    action.update sent_json: choose_cards_json(action, cards, maximum, minimum, message)

    WebsocketDataSender.send_game_data(game_player.player, game, action.sent_json)
    action
  end

  def self.send_choose_text_prompt(game, game_player, options, message, maximum=0, minimum=0, action_type=nil)
    action = TurnAction.create game: game, game_player: game_player, action: action_type
    action.update sent_json: choose_text_json(action, options, maximum, minimum, message)

    WebsocketDataSender.send_game_data(game_player.player, game, action.sent_json)
    action
  end

  def self.process_player_response(game, game_player, action, source)
    TurnActionHandler.wait_for_response(game)
    action = TurnAction.find_uncached action.id
    source.process_action(game, game_player, action)
    action.destroy
    ActiveRecord::Base.clear_active_connections!
  end

  def self.refresh_game_area(game, player)
    hand_json = refresh_game_json(game, player)
    WebsocketDataSender.send_game_data(player, game, hand_json)
  end

  def self.wait_for_card(card)
    unless card.play_thread.nil?
      while card.play_thread.alive? do
        sleep(0.5)
      end
    end
    unless card.attack_thread.nil?
      while card.attack_thread.alive? do
        sleep(0.5)
      end
    end
  end

  def self.wait_for_response(game)
    while Game.unfinished_actions(game.id) > 0 do
      sleep(0.5)
    end
  end

end
