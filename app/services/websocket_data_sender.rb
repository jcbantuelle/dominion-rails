class WebsocketDataSender

  def self.send_lobby_data(player, data)
    self.send_socket_data(ApplicationController.lobby[player.id], data) if ApplicationController.lobby[player.id]
  end

  def self.send_game_data(player, game, data)
    self.send_socket_data(ApplicationController.games[game.id][player.id], data) if ApplicationController.games[game.id][player.id]
  end

  def self.send_socket_data(socket, data)
    socket.send_data data
  end

end
