class TurnEnder

  def initialize(game)
    @game = game
  end

  def end_turn
    game_over? ? end_game : change_turn
  end

  private

  def game_over?
    three_empty_piles? || empty_victory_pile?
  end

  def end_game
    @game.end_game
  end

  def change_turn
    TurnChanger.new(@game).next_turn
  end

  def three_empty_piles?
    @game.game_cards.empty_piles.count >= 3
  end

  def empty_victory_pile?
    card_ids = Card.end_game_cards.map{ |card| card.id }
    @game.game_cards.by_card_id(card_ids).select{ |card| card.remaining == 0 }.count > 0
  end

end
