class TurnChanger

  def initialize(game)
    @game = game
    @game.current_turn(true)
  end

  def first_turn
    set_game_turn
    create_turn
  end

  def next_turn
    resolve_outpost
    clean_up
    set_game_turn
    create_turn
    update_log
    resolve_durations
  end

  private

  def next_player
    turn = (@next_turn - 1) % @game.player_count
    @game.game_players[turn]
  end

  def resolve_outpost
    if !@game.current_turn.outpost? && @game.current_player.player_cards.duration.select{ |c| c.name == 'outpost' }.count > 0
      @outpost = true
      @game.current_turn.add_outpost
    end
    @outpost ||= false
  end

  def clean_up
    resolve_schemes if @game.current_turn.schemes > 0
    resolve_discard_reactions
    discard_from_play
    draw_new_hand
    revert_band_of_misfits
  end

  def resolve_discard_reactions
    @game.current_player.in_play.each do |in_play_card|
      in_play_card.card.discard_reaction(@game, @game.current_player, :cleanup) if in_play_card.state != 'duration' && in_play_card.card.respond_to?(:discard_reaction)
    end
  end

  def discard_from_play
    @game.current_player.player_cards.where(state: %w[hand play]).update_all(state: 'discard')
  end

  def draw_new_hand
    draw_count = @outpost ? 3 : 5
    CardDrawer.new(@game.current_player).draw(draw_count, false)
  end

  def resolve_schemes
    @game.current_turn.schemes.times do |i|
      action = scheme_player_prompt
      process_scheme_response(action) unless action.response.empty?
      action.destroy
    end
  end

  def eligible_scheme_cards
    @game.current_player.in_play_without_duration.select(&:action?)
  end

  def scheme_player_prompt
    action = TurnActionHandler.send_choose_cards_prompt(@game, @game.current_player, eligible_scheme_cards, "You may choose a card to put on deck:", 1)
    TurnActionHandler.wait_for_response(@game)
    TurnAction.find_uncached action.id
  end

  def process_scheme_response(action)
    card = PlayerCard.find action.response
    @game.current_player.put_card_on_deck card
    LogUpdater.new(@game).put(@game.current_player, [card], 'deck', false)
  end

  def set_game_turn
    unless @outpost
      current_turn = @game.current_turn
      @next_turn = current_turn.nil? ? 1 : current_turn.turn + 1
    end
  end

  def create_turn
    if @outpost
      @game.current_turn.update actions: 1, buys: 1, coins: 0, potions: 0, phase: 'action', coppersmith: 0, global_discount: 0, played_actions: 0, tacticians: 0, lighthouse: 0, action_discount: 0, hoards: 0, talismans: 0, crossroads: 0
    else
      turn = Turn.create game_player: next_player, game: @game, turn: @next_turn
      @game.update_attribute :turn_id, turn.id
    end
  end

  def update_log
    if @outpost
      LogUpdater.new(@game).outpost_turn
    else
      LogUpdater.new(@game).end_turn
    end
  end

  def resolve_durations
    @game.current_player.duration.each do |player_card|
      card = player_card.card
      card.log_updater = LogUpdater.new @game
      card.duration(@game)
    end
    @game.current_player.duration.update_all(state: 'play')
  end

  def revert_band_of_misfits
    misfits_card_id = Card.by_name 'band_of_misfits'
    @game.current_player.player_cards.where(band_of_misfits: true).where.not(state: 'duration').update_all(card_id: misfits_card_id, band_of_misfits: false)
  end

end
