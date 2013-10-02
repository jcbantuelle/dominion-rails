class CardGainer

  BUY_REACTION_CARDS = %w(hovel)

  def initialize(game, player, card_name)
    @game = game
    @game.current_turn(true)
    @player = player
    @game_card = GameCard.find(GameCard.by_game_id_and_card_name(@game.id, card_name).first.id)
    @top_card = @game_card.name == 'ruins' || @game_card.name == 'knights' ? @game_card.mixed_game_cards.first : @game_card
  end

  def buy_card
    LogUpdater.new(@game).card_action(@player, @top_card, 'buy')
    add_to_deck('discard')
    @game.current_turn.buy_card @top_card.calculated_cost(@game, @game.current_turn)
    process_hoard if @game.current_turn.hoards > 0 && valid_hoard_gain?
    process_talisman if @game.current_turn.talismans > 0 && valid_talisman_gain?
    buy_reactions
  end

  def valid_buy?
    enough_buys? && affordable? && @game_card.available? && allowed_to_buy?
  end

  def gain_card(destination)
    if valid_gain?
      LogUpdater.new(@game).card_action(@player, @top_card, 'gain', destination)
      add_to_deck(destination)
    end
  end

  private

  def add_to_deck(destination)
    @game_card.update_attribute :remaining, @game_card.remaining - 1
    @top_card.destroy if @top_card.name != @game_card.name

    destination = @top_card.card.gain_destination(@game, @player) if @top_card.card.respond_to?(:gain_destination)

    @new_card_attributes = {
      game_player_id: @player.id,
      card_id: @top_card.card_id,
      state: destination
    }

    prepare_top_of_deck if destination == 'deck'
    PlayerCard.create @new_card_attributes

    @top_card.card.gain_event(@game, @player) if @top_card.card.respond_to?(:gain_event)
  end

  def enough_buys?
    @game.current_turn.buys > 0
  end

  def affordable?
    enough_coins? && enough_potions?
  end

  def valid_gain?
    @game_card.available?
  end

  def prepare_top_of_deck
    GamePlayer.find(@player.id).deck.update_all ['card_order = card_order + 1']
    @new_card_attributes[:card_order] = 1
  end

  def enough_coins?
    turn = @game.current_turn
    turn.coins >= @top_card.calculated_cost(@game, turn)[:coin]
  end

  def enough_potions?
    turn = @game.current_turn
    @top_card.calculated_cost(@game, turn)[:potion].nil? || turn.potions >= @top_card.calculated_cost(@game, turn)[:potion]
  end

  def allowed_to_buy?
    !@top_card.card.respond_to?(:allowed?) || @top_card.card.allowed?(@game)
  end

  def valid_hoard_gain?
    @top_card.card.victory_card?
  end

  def process_hoard
    hoard_count = @game.current_player.find_cards_in_play('hoard').count
    card_gainer = CardGainer.new @game, @game.current_player, 'gold'
    hoard_count.times do
      card_gainer.gain_card('discard')
    end
  end

  def valid_talisman_gain?
    card_cost = @top_card.calculated_cost(@game, @game.current_turn)
    !@top_card.card.victory_card? && card_cost[:coin] <= 4 && card_cost[:potion].nil?
  end

  def process_talisman
    talisman_count = @game.current_player.find_cards_in_play('talisman').count
    card_gainer = CardGainer.new @game, @game.current_player, @top_card.name
    talisman_count.times do
      card_gainer.gain_card('discard')
    end
  end

  def buy_reactions
    reaction_cards = []
    BUY_REACTION_CARDS.each do |reaction_card_name|
      reaction_cards += @game.current_player.find_cards_in_hand(reaction_card_name)
    end
    reaction_cards.each do |reaction_card|
      reaction_card.card.reaction(@game, @game.current_player, @top_card)
      TurnActionHandler.wait_for_card(reaction_card.card)
    end
  end

end
