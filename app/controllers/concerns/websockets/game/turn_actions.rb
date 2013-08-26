module Websockets::Game::TurnActions

  def end_turn(data)
    if can_play?
      TurnEnder.new(@game).end_turn
      send_end_turn_data
    end
  end

  def play_card(data)
    if can_play?
      player = CardPlayer.new @game, data['card_id']
      if player.valid_play?
        player.play_card
        send_card_action_data('play')
      end
    end
  end

  def buy_card(data)
    if can_play?
      gainer = CardGainer.new @game, @game.current_player, data['card_id']
      if gainer.valid_buy?
        gainer.buy_card
        send_card_action_data('buy')
      end
    end
  end

  private

  def can_play?
    @game.current_player.player_id == current_player.id
  end

  def send_card_action_data(action)
    @game.players.each do |player|
      WebsocketDataSender.send_game_data player, @game, send("#{action}_card_json", @game, player)
    end
  end

  def send_end_turn_data
    @game.players.each do |player|
      json_content = @game.finished? ? end_game_json(@game, player) : end_turn_json(@game, player)
      WebsocketDataSender.send_game_data player, @game, json_content
    end
  end
end
