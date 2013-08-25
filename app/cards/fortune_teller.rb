module FortuneTeller

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 3
    }
  end

  def type
    [:action, :attack]
  end

  def play(game)
    game.current_turn.add_coins(2)
    @log_updater.get_from_card(game.current_player, '+$2')
  end

  def attack(game, player)
    @revealed = []
    reveal_cards(game, player)
    @log_updater.reveal(player, @revealed, 'deck')
    discard_revealed(game, player)
  end

  private

  def reveal_cards(game, player)
    player.deck.each do |card|
      @revealed << card
      if valid_card?(card)
        @valid_card = card
        break
      else
        card.update_attribute :state, 'revealed'
      end
    end

    continue_revealing(game, player) unless reveal_finished?(game, player)
  end

  def continue_revealing(game, player)
    player.shuffle_discard_into_deck
    reveal_cards(game, player)
  end

  def discard_revealed(game, player)
    player.discard_revealed
    @log_updater.put(player, [@valid_card], 'deck')
  end

  def reveal_finished?(game, player)
    @valid_card.present? || player.discard.count == 0
  end

  def valid_card?(card)
    card.victory? || card.curse?
  end

end
