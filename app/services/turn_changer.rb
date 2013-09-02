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
    @game.current_player.player_cards.where(state: %w[hand play]).update_all(state: 'discard')
    draw_count = @outpost ? 3 : 5
    CardDrawer.new(@game.current_player).draw(draw_count, false)
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
end
