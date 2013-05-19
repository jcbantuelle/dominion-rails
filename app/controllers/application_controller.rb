class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_lobby
  before_filter :player_activity
  before_filter :configure_permitted_parameters, if: :devise_controller?

protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password) }
  end

  def devise_parameter_sanitizer
    if resource_class.is_a?(Player)
      Player::ParameterSanitizer.new(Player, :player, params)
    else
      super # Use the default one
    end
  end

private

  def set_lobby(in_lobby = false)
    current_player.update_attribute(:lobby, in_lobby) if current_player
  end

  def player_activity
    current_player.try :touch, :last_response_at
  end
end
