module Websockets::Game::TurnActions

  def end_turn(data)
    TurnChanger.new(@game).next_turn
    @game.players.each do |player|
      send_game_data player, @game, end_turn_json(@game, player)
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
      service_class = "Card#{action.titleize}er".constantize
      card_service = service_class.new @game, data['card_id']
      if card_service.send("valid_#{action}?")
        card_service.send("#{action}_card")
        @game.players.each do |player|
          send_game_data player, @game, send("#{action}_card_json", @game, player, card_service)
        end
      end
    end
  end
end
