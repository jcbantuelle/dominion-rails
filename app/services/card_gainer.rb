class CardGainer

  BUY_REACTION_CARDS = %w(hovel)
  GAIN_REACTION_CARDS = %w(fools_gold watchtower)

  def initialize(game, player, card_name)
    @game = game
    @game.current_turn(true)
    @player = player
    @game_card = GameCard.find(GameCard.by_game_id_and_card_name(@game.id, card_name).first.id)
    @top_card = @game_card.name == 'ruins' || @game_card.name == 'knights' ? @game_card.mixed_game_cards.first : @game_card
  end

  def buy_card
    LogUpdater.new(@game).card_action(@player, @top_card, 'buy')
    add_to_deck('discard', 'buy')
    @game.current_turn.buy_card @top_card.calculated_cost(@game, @game.current_turn)
    process_hoard if @game.current_turn.hoards > 0 && valid_hoard_gain?
    process_talisman if @game.current_turn.talismans > 0 && valid_talisman_gain?
    process_haggler if @game.current_turn.hagglers > 0
    process_goons if @game.current_turn.goons > 0
    gain_reactions('buy')
  end

  def valid_buy?
    enough_buys? && affordable? && @game_card.available? && allowed_to_buy?
  end

  def gain_card(destination)
    if valid_gain?
      LogUpdater.new(@game).card_action(@player, @top_card, 'gain', destination)
      add_to_deck(destination, 'gain')
      gain_reactions('gain')
    end
  end

  private

  def add_to_deck(destination, event)
    @destination = destination
    trader_reaction
    @game_card.update_attribute :remaining, @game_card.remaining - 1
    if @game_card.has_trade_route_token
      @game.add_trade_route_token
      @game_card.remove_trade_route_token
    end
    @top_card.destroy if @top_card.name != @game_card.name

    @destination = @top_card.card.gain_destination(@game, @player) if @top_card.card.respond_to?(:gain_destination)

    process_royal_seal if @game.current_turn.royal_seal

    @new_card_attributes = {
      game_player_id: @player.id,
      card_id: @top_card.card_id,
      state: @destination
    }

    prepare_top_of_deck if @destination == 'deck'
    @gained_card = PlayerCard.create @new_card_attributes

    @top_card.card.gain_event(@game, @player, event) if @top_card.card.respond_to?(:gain_event)
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
    (!@top_card.card.respond_to?(:allowed?) || @top_card.card.allowed?(@game)) && !contraband?
  end

  def contraband?
    contraband = @game.current_turn.contraband
    !contraband.nil? && contraband.split.include?(@game_card.id.to_s)
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

  def process_haggler
    haggler_count = @game.current_player.find_cards_in_play('haggler').count
    haggler = Card.by_name('haggler')

    card_cost = @top_card.calculated_cost(@game, @game.current_turn)
    available_cards = @game.cards_costing_less_than(card_cost[:coin], card_cost[:potion]).reject(&:victory_card?)

    haggler_count.times do
      if available_cards.count == 0
        LogUpdater.new(@game).custom_message(nil, "But there are no available cards to gain from #{haggler.card_html}".html_safe)
      elsif available_cards.count == 1
        CardGainer.new(@game, @game.current_player, available_cards.first.name).gain_card('discard')
      else
        action = send_haggler_prompt(haggler, available_cards)
        process_haggler_response(action)
        action.destroy
      end
    end
  end

  def send_haggler_prompt(haggler, available_cards)
    action = TurnActionHandler.send_choose_cards_prompt(@game, @game.current_player, available_cards, "Choose a card to gain from #{haggler.card_html}:", 1, 1)
    TurnActionHandler.wait_for_response(@game)
    TurnAction.find_uncached action.id
  end

  def process_haggler_response(action)
    gained_card = GameCard.find(action.response)
    CardGainer.new(@game, @game.current_player, gained_card.name).gain_card('discard')
  end

  def process_royal_seal
    action = send_royal_seal_prompt
    process_royal_seal_response(action)
    action.destroy
  end

  def process_goons
    @player.add_victory_tokens(@game.current_turn.goons)
    LogUpdater.new(@game).custom_message(@player, "+#{@game.current_turn.goons} &nabla;".html_safe, 'gain')
  end

  def send_royal_seal_prompt
    options = [
      { text: 'Yes', value: 'yes' },
      { text: 'No', value: 'no' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(@game, @game.current_player, options, "Put #{@top_card.card.card_html} on top of deck?".html_safe, 1, 1)
    TurnActionHandler.wait_for_response(@game)
    TurnAction.find_uncached action.id
  end

  def process_royal_seal_response(action)
    if action.response == 'yes'
      @destination = 'deck'
      LogUpdater.new(@game).put(@game.current_player, [@top_card], 'deck', false)
    end
  end

  def gain_reactions(event)
    @game.turn_ordered_players.each do |game_player|
      reaction_cards = []
      if event == 'buy'
        BUY_REACTION_CARDS.each do |reaction_card_name|
          reaction_cards += game_player.find_cards_in_hand(reaction_card_name)
        end
      end
      GAIN_REACTION_CARDS.each do |reaction_card_name|
        reaction_cards += game_player.find_cards_in_hand(reaction_card_name)
      end
      reaction_cards.each do |reaction_card|
        reaction_card.card.reaction(@game, game_player, @gained_card)
        TurnActionHandler.wait_for_card(reaction_card.card)
        ActiveRecord::Base.connection.clear_query_cache
      end
    end
  end

  def trader_reaction
    trader = @player.find_card_in_hand('trader')
    if trader
      action = send_trader_prompt(trader)
      process_trader_response(trader, action)
      action.destroy
    end
  end

  def send_trader_prompt(trader)
    options = [
      { text: 'Yes', value: 'yes' },
      { text: 'No', value: 'no' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(@game, @player, options, "Reveal #{trader.card.card_html}?".html_safe, 1, 1)
    TurnActionHandler.wait_for_response(@game)
    TurnAction.find_uncached action.id
  end

  def process_trader_response(trader, action)
    if action.response == 'yes'
      @game_card = GameCard.find(GameCard.by_game_id_and_card_name(@game.id, 'silver').first.id)
      @top_card = @game_card
      LogUpdater.new(@game).reveal(@player, [trader], 'hand')
      LogUpdater.new(@game).custom_message(@player, "a #{@game_card.card.card_html} instead".html_safe, 'gain')
    end
  end

end
