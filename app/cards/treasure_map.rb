module TreasureMap

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    if trash_treasure_maps(game)
      4.times do
        give_card_to_player(game, game.current_player, 'gold', 'deck')
      end
    end
  end

  def trash_treasure_maps(game)
    map_in_play = game.current_player.find_card_in_play('treasure_map')
    CardTrasher.new(game.current_player, [map_in_play]).trash
    map_in_hand = game.current_player.find_card_in_hand('treasure_map')
    CardTrasher.new(game.current_player, [map_in_hand]).trash('hand') unless map_in_hand.nil?
    map_in_hand.present?
  end
end
