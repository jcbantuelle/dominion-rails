class TurnChanger

  def initialize(game)
    @game = game
  end

  def first_turn
    set_game_turn
    create_turn
  end

  def next_turn
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

  def clean_up
    @game.current_player.player_cards.where(state: %w[hand play]).update_all(state: 'discard')
    CardDrawer.new(@game.current_player).draw(5, false)
  end

  def set_game_turn
    current_turn = @game.current_turn
    @next_turn = current_turn.nil? ? 1 : current_turn.turn + 1
  end

  def create_turn
    turn = Turn.create game_player: next_player, game: @game, turn: @next_turn, actions: 1, buys: 1, coins: 0, potions: 0, phase: 'action'
    @game.update_attribute :turn_id, turn.id
  end

  def update_log
    LogUpdater.new(@game).end_turn
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
