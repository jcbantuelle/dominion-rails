module ApplicationHelper

  INDENTED_ACTIONS = %w[gain]

  def player_name(game_player, player)
    same_player?(game_player, player) ? 'You' : game_player.username
  end

  def player_action(game_player, player, action)
    same_player?(game_player, player) ? action : action.pluralize
  end

  def same_player?(game_player, player)
    game_player.player_id == player.player_id
  end

  def show_cards(cards)
    if cards.compact.blank?
      "nothing"
    else
      cards.map{ |card|
        "<span class=\"#{card.type_class}\">#{card.name.titleize}</span>"
      }.join(' ').html_safe
    end
  end

  def indent_message(action)
    '&nbsp;&nbsp;'.html_safe if INDENTED_ACTIONS.include?(action)
  end

  def conjugate(game_player, player, action)
    same_player = same_player?(game_player, player)
    case action
    when 'be'
      same_player ? 'are' : 'is'
    when 'have'
      same_player ? 'have' : 'has'
    else
      same_player ? action : action.pluralize
    end
  end

  def card_destination(destination)
    message = destination == 'deck' ? 'on ' : 'in '
    message += destination
  end

end
