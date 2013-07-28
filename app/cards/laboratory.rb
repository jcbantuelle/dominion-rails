module Laboratory

  def starting_count(game)
    10
  end

  def cost
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play(game)
    game.current_turn.add_actions(1)
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(2)
  end

  def log(game, player)
    message = game.current_player.player_id == player.id ? 'You play' : "#{game.current_player.username} plays"
    message += " a <span class=\"#{type_class}\">Laboratory</span> drawing "
    if game.current_player.player_id == player.id
      message += @card_drawer.drawn_cards.map{ |card|
        "<span class=\"#{card.type_class}\">#{card.name.titleize}</span>"
      }.join(' ')
    else
      message += "#{@card_drawer.drawn_cards.count} card(s)"
    end
    message += " and getting +1 action."
  end
end
