module FortuneTeller

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 3
    }
  end

  def type
    [:action, :attack]
  end

  def play(game, clone=false)
    game.current_turn.add_coins(2)
    @log_updater.get_from_card(game.current_player, '+$2')
  end

  def attack(game, players)
    players.each do |player|
      @revealed = []
      @valid_card = nil
      reveal_cards(game, player)
      @log_updater.reveal(player, @revealed, 'deck')
      discard_revealed(game, player)
    end
  end

  private

  def process_revealed_card(card)
    if valid_card?(card)
      @valid_card = card
    else
      card.update_attribute :state, 'revealed'
    end
    valid_card?(card)
  end

  def discard_revealed(game, player)
    revealed_cards = player.player_cards.revealed
    @log_updater.put(player, [@valid_card], 'deck', false) unless @valid_card.nil?
    CardDiscarder.new(player, revealed_cards).discard
  end

  def reveal_finished?(game, player)
    @valid_card.present? || player.discard.count == 0
  end

  def valid_card?(card)
    card.victory? || card.curse?
  end

end
