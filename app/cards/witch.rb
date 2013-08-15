module Witch

  def starting_count(game)
    10
  end

  def cost
    {
      coin: 5
    }
  end

  def type
    [:action, :attack]
  end

  def play(game)
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(2)

    curse = Card.by_name 'curse'
    game_card = game.game_cards.by_card_id(curse.id).first

    game.game_players.each do |player|
      unless player.id == game.current_player.id
        CardGainer.new(game, player, game_card.id).gain_card('discard')
      end
    end
  end
end
