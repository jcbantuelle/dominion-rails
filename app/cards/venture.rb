module Venture

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 5
    }
  end

  def type
    [:treasure]
  end

  def play(game, clone=false)
    game.current_turn.add_coins(1)
    @log_updater.get_from_card(game.current_player, '+$1')
    reveal(game)
    discard_revealed(game)
    play_treasure(game) unless @treasure.nil?
  end

  private

  def reveal(game)
    @revealed = []
    reveal_cards(game, game.current_player)
    @log_updater.reveal(game.current_player, @revealed, 'deck')
  end

  def process_revealed_card(card)
    if card.treasure?
      @treasure = card
    else
      card.update_attribute :state, 'revealed'
    end
    card.treasure?
  end

  def discard_revealed(game)
    game.current_player.discard_revealed
    @log_updater.put(game.current_player, [@treasure], 'play')
  end

  def reveal_finished?(game, player)
    @treasure.present? || game.current_player.discard.count == 0
  end

  def play_treasure(game)
    @treasure.update_attribute :state, 'play'
    game.current_player.player_cards.reload
    played_card = @treasure.card
    played_card.log_updater = LogUpdater.new game
    played_card.play(game)
  end
end
