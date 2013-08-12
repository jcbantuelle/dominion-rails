module Websockets::Game::TurnActions

  def end_turn(data)
    TurnChanger.new(@game).next_turn
    LogUpdater.new(@game).end_turn
    @game.players.each do |player|
      WebsocketDataSender.send_game_data player, @game, end_turn_json(@game, player)
    end
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
      if card_service.valid?
        card_service.send("#{action}_card")
        @game.players.each do |player|
          WebsocketDataSender.send_game_data player, @game, send("#{action}_card_json", @game, player)
        end
      end
    end
  end

  def new_service(action, data)
    "Card#{action.titleize}er".constantize.new @game, data['card_id']
  end
end
