class CardGainer

  def initialize(game, player, card_id)
    @game = game
    @player = player
    @card = @game.game_cards.find card_id
  end

  def buy_card
    add_to_deck('discard')
    LogUpdater.new(@game).card_action(@player, @card, 'buy')
    @game.current_turn.buy_card @card.cost(@game)
    process_hoard if @card.card.victory_card?
  end

  def valid_buy?
    enough_buys? && affordable? && @card.available? && allowed_to_buy?
  end

  def gain_card(destination)
    if valid_gain?
      add_to_deck(destination)
      LogUpdater.new(@game).card_action(@player, @card, 'gain', destination)
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

  def enough_buys?
    @game.current_turn.buys > 0
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

  def allowed_to_buy?
    !@card.card.respond_to?(:allowed?) || @card.card.allowed?(@game)
  end

  def process_hoard
    gold = GameCard.by_card_name('gold').first
    card_gainer = CardGainer.new @game, @game.current_player, gold.id
    @game.current_turn.hoards.times do
      card_gainer.gain_card('discard')
    end
  end

end
