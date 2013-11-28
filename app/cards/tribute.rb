class Tribute < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    reveal(game)
    gain_from_revealed(game)
  end

  def gain_from_revealed(game)
    actions = 0
    coins = 0
    cards = 0
    gain = []
    revealed_names = []
    @revealed.each do |card|
      unless revealed_names.include? card.name
        if card.card.action_card?
          game.current_turn.add_actions(2)
          actions += 2
        end
        if card.card.treasure_card?
          game.current_turn.add_coins(2)
          coins += 2
        end
        if card.card.victory_card?
          cards += 2
        end
        revealed_names << card.name
      end
    end
    CardDrawer.new(game.current_player).draw(cards) unless cards == 0
    gain << "+#{actions} actions" unless actions == 0
    gain << "+#{coins} coins" unless coins == 0
    LogUpdater.new(game).get_from_card(game.current_player, gain.join(', ')) unless gain.empty?
  end

  def reveal(game)
    @revealed = []
    player_to_left = game.player_to_left(game.current_player)
    reveal_cards(game, player_to_left)
    @log_updater.reveal(player_to_left, @revealed, 'deck')
    CardDiscarder.new(player_to_left, @revealed).discard
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 2
  end

  def reveal_finished?(game, player)
    @revealed.count == 2 || game.current_player.discard.count == 0
  end
end
