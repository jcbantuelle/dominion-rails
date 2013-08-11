module ApplicationHelper

  def same_player?(game_player, player)
    game_player.player_id == player.id
  end

  def show_cards(cards)
    cards.map{ |card|
      "<span class=\"#{card.type_class}\">#{card.name.titleize}</span>"
    }.join(' ').html_safe
  end
end
