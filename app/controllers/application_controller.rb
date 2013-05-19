class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_lobby
  before_filter :player_activity

private

  def set_lobby(in_lobby = false)
    current_player.update_attribute :lobby, in_lobby
  end

  def player_activity
    current_player.try :touch, :last_response_at
  end
end
