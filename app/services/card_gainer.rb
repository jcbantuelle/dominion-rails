class CardGainer

  def initialize(game, player, card_id)
    @game = game
    @game.reload
    @player = player
    @card = @game.game_cards.find card_id
  end

  def buy_card
    add_to_deck('discard')
    LogUpdater.new(@game).card_action(@player, @card, 'buy')
    @game.current_turn.buy_card @card.cost(@game)
  end

  def valid_buy?
    affordable? && @card.available?
  end

  def gain_card(destination)
    if valid_gain?
      add_to_deck(destination)
      LogUpdater.new(@game).card_action(@player, @card, 'gain')
    end
  end

  private

  def add_to_deck(destination)
    @card.update_attribute :remaining, @card.remaining - 1

    @new_card_attributes = {
      game_player_id: @player.id,
      card_id: @card.card_id,
      state: destination
    }

    prepare_top_of_deck if destination == 'deck'
    PlayerCard.create @new_card_attributes
  end

  def affordable?
    enough_coins? && enough_potions?
  end

  def valid_gain?
    @card.available?
  end

  def prepare_top_of_deck
    GamePlayer.find(@player.id).deck.update_all ['card_order = card_order + 1']
    @new_card_attributes[:card_order] = 1
  end

  def enough_coins?
    @game.current_turn.coins >= @card.cost(@game)[:coin]
  end

  def enough_potions?
    @card.cost(@game)[:potion].nil? || @game.current_turn.potions >= @card.cost(@game)[:potion]
  end

end
