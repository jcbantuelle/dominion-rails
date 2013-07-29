module ApplicationHelper

  def same_player?(game_player, player)
    game_player.player_id == player.id
  end
end
