module Websockets::Game::TurnActions

  def end_turn(data)
    TurnChanger.new(@game).next_turn
    refresh_all
  end
end
