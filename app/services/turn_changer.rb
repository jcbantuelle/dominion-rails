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
  end

  private

  def next_player
    turn = (@game.turn % @game.player_count) - 1
    @game.game_players[turn]
  end

  def clean_up
    @game.current_player.player_cards.where(state: %w[hand play]).update_all(state: 'discard')
    CardDrawer.new(@game.current_player).draw(5)
  end

  def set_game_turn
    turn = @game.turn.nil? ? 1 : @game.turn+1
    @game.update_attribute :turn, turn
    @game.reload
  end

  def create_turn
    Turn.create game_player: next_player, game: @game, turn: @game.turn, actions: 1, buys: 1, coins: 0
  end
end
