module Websockets::Game::TurnActions

  def end_turn(data)
    TurnChanger.new(@game).next_turn
    @game.players.each do |player|
      send_game_data player, @game, end_turn_json(@game, player)
    end
  end
end
