class PlayerAccepter

  def self.accept(game, player)
    game.game_player(player.id).update_attribute(:accepted, true)
  end
end
