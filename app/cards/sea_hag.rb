module SeaHag

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 4
    }
  end

  def type
    [:action, :attack]
  end

  def play(game)
    discard_top_card(game)
    give_card_to_players(game, 'curse', 'deck')
  end

  def discard_top_card(game)
    game.game_players.each do |player|
      unless player.id == game.current_player.id
        binding.pry
        player.shuffle_discard_into_deck if player.needs_reshuffle?
        unless player.empty_deck?
          card = player.player_cards.deck.first
          card.update_attribute :state, 'discard'
          @log_updater.discard(player, [card], 'deck')
        end
      end
    end
  end

end
