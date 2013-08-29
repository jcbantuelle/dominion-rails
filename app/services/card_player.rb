class CardPlayer

  def initialize(game, card_id)
    @game = game
    @card = Card.find card_id
  end

  def play_card
    move_from_hand_to_play
    play
    attack
  end

  def valid_play?
    has_card? && @card.playable? && (valid_action? || valid_treasure?)
  end

  private

  def valid_action?
    @card.action_card? && @game.current_turn.action_phase? && @game.current_turn.actions > 0
  end

  def valid_treasure?
    @card.treasure_card? && (@game.current_turn.action_phase? || @game.current_turn.treasure_phase?)
  end

  def move_from_hand_to_play
    new_state = @card.duration_card? ? 'duration' : 'play'
    @game.current_player.hand.where(card_id: @card.id).first.update_attribute(:state, new_state)
    @game.current_turn.add_played_action if @card.action_card?
  end

  def play
    treasure_phase if @card.treasure_card?
    play_action if @card.action_card?
    @card.play_log(@game.current_player, @game)
    @card.play(@game)
  end

  def attack
    if @card.attack_card?
      @game.game_players.each do |player|
        unless not_attackable?(player)
          @card.attack(@game, player)
        end
      end
    end
  end

  def treasure_phase
    @game.current_turn.treasure_phase
  end

  def play_action
    @game.current_turn.play_action
  end

  def has_card?
    @game.current_player.hand.where(card_id: @card.id).count > 0
  end

  def not_attackable?(player)
    myself?(player) || immune_to_attack?(player)
  end

  def myself?(player)
    player.id == @game.current_player.id
  end

  def immune_to_attack?(player)
    immune = false
    if player.turns.present? && player.turns[0].lighthouse
      immune = true
      lighthouse = Card.by_name 'lighthouse'
      LogUpdater.new(@game).immune_to_attack(player, lighthouse.card_html)
    end
    immune
  end

end
