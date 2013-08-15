module Websockets::Game::TurnActions

  def end_turn(data)
    TurnEnder.new(@game).end_turn
    send_end_turn_data
  end

  def play_card(data)
    card_action('play', data)
  end

  def buy_card(data)
    card_action('buy', data)
  end

  private

  def card_action(action, data)
    if @game.current_player.player_id == current_player.id
      card_service = new_service(action, data)
      if card_service.send("valid_#{action}?")
        card_service.send("#{action}_card")
        @game.players.each do |player|
          WebsocketDataSender.send_game_data player, @game, send("#{action}_card_json", @game, player)
        end
      end
    end
  end

  def new_service(action, data)
    action = 'gain' if action == 'buy'
    "Card#{action.titleize}er".constantize.new @game, data['card_id']
  end

  def send_end_turn_data
    @game.players.each do |player|
      json_content = @game.finished? ? end_game_json(@game, player) : end_turn_json(@game, player)
      WebsocketDataSender.send_game_data player, @game, json_content
    end
  end
end
