class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :unset_lobby
  before_filter :player_activity
  before_filter :log_out_inactive_players
  before_filter :configure_permitted_parameters, if: :devise_controller?

  @@lobby = {}

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

  def set_lobby
    update_lobby true
  end

  def unset_lobby
    update_lobby false
  end

  def update_lobby(in_lobby)
    current_player.update_attribute(:lobby, in_lobby) if current_player
  end

  def player_activity
    if current_player
      current_player.touch :last_response_at
      current_player.online = true
      current_player.save
    end
  end

  def log_out_inactive_players
    Player.inactive.update_all(online: false)
    refresh_lobby
  end

  def refresh_lobby
    players = Player.online.in_lobby
    player_ids = players.collect(&:id)
    @@lobby.select! { |id, socket| player_ids.include? id }
    @@lobby.each_pair do |player_id, socket|
      lobby_players = players.reject{ |p| p.id == player_id }
      socket.send_data({action: 'refresh', players: lobby_players}.to_json) unless lobby_players.blank?
    end
  end
end
