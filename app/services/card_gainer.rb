class CardGainer

  BUY_REACTION_CARDS = %w(hovel)

  def initialize(game, player, card_id)
    @game = game
    @game.current_turn(true)
    @player = player
    @card = @game.game_cards.find card_id
  end

  def buy_card
    LogUpdater.new(@game).card_action(@player, @card, 'buy')
    add_to_deck('discard')
    @game.current_turn.buy_card @card.calculated_cost(@game)
    process_hoard if @game.current_turn.hoards > 0 && valid_hoard_gain?
    process_talisman if @game.current_turn.talismans > 0 && valid_talisman_gain?
    buy_reactions
  end

  def valid_buy?
    enough_buys? && affordable? && @card.available? && allowed_to_buy?
  end

  def gain_card(destination)
    if valid_gain?
      LogUpdater.new(@game).card_action(@player, @card, 'gain', destination)
      add_to_deck(destination)
    end
  end

  private

  def add_to_deck(destination)
    @card.update_attribute :remaining, @card.remaining - 1

    destination = @card.card.gain_destination(@game, @player) if @card.card.respond_to?(:gain_destination)

    @new_card_attributes = {
      game_player_id: @player.id,
      card_id: @card.card_id,
      state: destination
    }

    prepare_top_of_deck if destination == 'deck'
    PlayerCard.create @new_card_attributes

    @card.card.gain_event(@game, @player) if @card.card.respond_to?(:gain_event)
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
    @game.current_turn.coins >= @card.calculated_cost(@game)[:coin]
  end

  def enough_potions?
    @card.calculated_cost(@game)[:potion].nil? || @game.current_turn.potions >= @card.calculated_cost(@game)[:potion]
  end

  def allowed_to_buy?
    !@card.card.respond_to?(:allowed?) || @card.card.allowed?(@game)
  end

  def valid_hoard_gain?
    @card.card.victory_card?
  end

  def process_hoard
    gold = GameCard.by_game_id_and_card_name(@game.id, 'gold').first
    card_gainer = CardGainer.new @game, @game.current_player, gold.id
    @game.current_turn.hoards.times do
      card_gainer.gain_card('discard')
    end
  end

  def valid_talisman_gain?
    card_cost = @card.calculated_cost(@game)
    !@card.card.victory_card? && card_cost[:coin] <= 4 && card_cost[:potion].nil?
  end

  def process_talisman
    card_gainer = CardGainer.new @game, @game.current_player, @card.id
    @game.current_turn.talismans.times do
      card_gainer.gain_card('discard')
    end
  end

  def buy_reactions
    reaction_cards = []
    BUY_REACTION_CARDS.each do |reaction_card_name|
      reaction_cards += @game.current_player.find_cards_in_hand(reaction_card_name)
    end
    reaction_cards.each do |reaction_card|
      reaction_card.card.reaction(@game, @game.current_player, @card)
      TurnActionHandler.wait_for_card(reaction_card.card)
    end
  end

end
