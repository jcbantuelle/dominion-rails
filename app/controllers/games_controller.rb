class GamesController < ApplicationController
  before_filter :authenticate_player!

  def new
    set_lobby true
    @players = Player.online.in_lobby
  end
end
