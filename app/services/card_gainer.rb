class CardGainer

  def initialize(game, card_id)
    @game = game
    @game.reload
    @card = @game.game_cards.find card_id
  end

  def buy_card
    add_to_deck(@game.current_player.id, 'discard')
    LogUpdater.new(@game).card_action(@card, 'buy')
    @game.current_turn.buy_card @card.cost
  end

  def valid_buy?
    affordable? && @card.available?
  end

  def gain_card(player_id, destination)
    add_to_deck(player_id, destination) if valid_gain?
  end

  private

  def add_to_deck(player_id, destination)
    @card.update_attribute :remaining, @card.remaining - 1

    @new_card_attributes = {
      game_player_id: player_id,
      card_id: @card.card_id,
      state: destination
    }

    prepare_top_of_deck(player_id) if destination == 'deck'
    PlayerCard.create @new_card_attributes
  end

  def affordable?
    @game.current_turn.coins >= @card.cost[:coin]
  end

  def valid_gain?
    @card.available?
  end

  def prepare_top_of_deck(player_id)
    GamePlayer.find(player_id).deck.update_all ['card_order = card_order + 1']
    @new_card_attributes[:card_order] = 1
  end

end
