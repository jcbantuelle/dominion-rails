class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_thread_exception_reporting
  before_filter :unset_lobby_status
  before_filter :keep_player_active
  before_filter :clear_finished_games
  before_filter :log_out_inactive_players
  before_filter :configure_permitted_parameters, if: :devise_controller?

  cattr_accessor :lobby, instance_accessor: false do
    {}
  end
  cattr_accessor :games, instance_accessor: false do
    {}
  end

  include LobbyManagement, LoginManagement

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

  def process_message(data)
    send(data['action'], data) if respond_to?(data['action'])
  end

  def set_thread_exception_reporting
    Thread.abort_on_exception = true
  end

end
