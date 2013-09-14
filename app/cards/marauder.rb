module Marauder

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:action, :attack, :looter]
  end

  def play(game, clone=false)
    CardGainer.new(game, game.current_player, 'spoils').gain_card('discard')
  end

  def attack(game, players)
    players.each do |player|
      give_card_to_player(game, player, 'ruins', 'discard')
    end
  end

end
