module Smithy

  def starting_count(game)
    10
  end

  def cost
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game)
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(3)
  end

  def log(game, player)
    message = game.current_player.player_id == player.id ? 'You play' : "#{game.current_player.username} plays"
    message += " a <span class=\"#{type_class}\">Smithy</span> drawing "
    if game.current_player.player_id == player.id
      message += @card_drawer.drawn_cards.map{ |card|
        "<span class=\"#{card.type_class}\">#{card.name.titleize}</span>"
      }.join(' ')
    else
      message += "#{@card_drawer.drawn_cards.count} card(s)"
    end
    message += "."
  end
end
