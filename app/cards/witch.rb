module Witch

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action, :attack]
  end

  def play(game, clone=false)
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(2)
  end

  def attack(game, players)
    players.each do |player|
      give_card_to_player(game, player, 'curse', 'discard')
    end
  end
end
