module ApplicationHelper

  INDENTED_ACTIONS = %w[gain]

  def player_name(game_player, player)
    same_player?(game_player, player) ? 'You' : game_player.username
  end

  def player_action(game_player, player, action)
    same_player?(game_player, player) ? action : "#{action}s"
  end

  def same_player?(game_player, player)
    game_player.player_id == player.player_id
  end

  def show_cards(cards)
    cards.map{ |card|
      "<span class=\"#{card.type_class}\">#{card.name.titleize}</span>"
    }.join(' ').html_safe
  end

  def indent_message(action)
    '&nbsp;&nbsp;'.html_safe if INDENTED_ACTIONS.include?(action)
  end

end
