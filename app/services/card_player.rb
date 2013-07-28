class CardPlayer

  def initialize(game, card_id)
    @game = game
    @card = Card.find card_id
    @game.reload
  end

  def play_card
    move_from_hand_to_play
    play
  end

  def valid_play?
    has_card? && @card.playable? && (valid_action? || valid_treasure?)
  end

  def log(player)
    @card.log(@game, player)
  end

  private

  def valid_action?
    @card.action_card? && @game.current_turn.phase == 'action' && @game.current_turn.actions > 0
  end

  def valid_treasure?
    @card.treasure_card?
  end

  def move_from_hand_to_play
    @game.current_player.hand.where(card_id: @card.id).first.update_attribute(:state, 'play')
  end

  def play
    buy_phase if @card.treasure_card?
    play_action if @card.action_card?
    @card.play(@game)
  end

  def buy_phase
    @game.current_turn.buy_phase
  end

  def play_action
    @game.current_turn.play_action
  end

  def has_card?
    @game.current_player.hand.where(card_id: @card.id).count > 0
  end

end
