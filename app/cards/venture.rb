module Venture

  def starting_count(game)
    10
  end

  def cost(game, turn)
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
    @log_updater.put(game.current_player, [@treasure], 'play', false)
    revealed_cards = game.current_player.player_cards.revealed
    CardDiscarder.new(game.current_player, revealed_cards).discard
  end

  def reveal_finished?(game, player)
    @treasure.present? || game.current_player.discard.count == 0
  end

  def play_treasure(game)
    @treasure.update_attribute :state, 'play'
    ActiveRecord::Base.connection.clear_query_cache
    played_card = @treasure.card
    played_card.log_updater = LogUpdater.new game
    played_card.play(game)
  end
end
