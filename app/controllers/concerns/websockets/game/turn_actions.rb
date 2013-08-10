module Websockets::Game::TurnActions

  def end_turn(data)
    TurnChanger.new(@game).next_turn
    @game.players.each do |player|
      send_game_data player, @game, end_turn_json(@game, player)
    end
  end

  def play_card(data)
    if @game.current_player.player_id == current_player.id
      card_player = CardPlayer.new(@game, data['card_id'])
      if card_player.valid_play?
        card_player.play_card
        @game.players.each do |player|
          send_game_data player, @game, play_card_json(@game, player, card_player)
        end
      end
    end
  end

  def buy_card(data)
    if @game.current_player.player_id == current_player.id
      card_buyer = CardBuyer.new(@game, data['card_id'])
      if card_buyer.valid_buy?
        card_buyer.buy_card
        @game.players.each do |player|
          send_game_data player, @game, buy_card_json(@game, player, card_buyer)
        end
      end
    end
  end
end
