class CardPlayer

  ATTACK_REACTION_CARDS = %w(secret_chamber)

  def initialize(game, card_id, free_action=false, clone=false)
    @game = game
    @game.current_turn(true)
    @card = Card.find card_id
    @free_action = free_action
    @clone = clone
  end

  def play_card
    move_from_hand_to_play unless @clone
    play
    TurnActionHandler.wait_for_card(@card)
    attack
    @card
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
    play_action if @card.action_card? && !@free_action
    @card.play_log(@game.current_player, @game)
    @card.play(@game, @clone)
  end

  def attack
    if @card.attack_card?
      @card.attack(@game, attacked_players)
    end
  end

  def attacked_players
    turn = @game.current_player.turn_order - 1
    players = @game.game_players
    turn_ordered_players = players.slice(turn..players.size) + players.slice(0, turn)

    attack_reactions(turn_ordered_players)

    turn_ordered_players.reject{ |player| not_attackable?(player) }
  end

  def attack_reactions(players)
    players.each do |player|
      unless myself?(player)
        reaction_cards = []
        ATTACK_REACTION_CARDS.each do |reaction_card_name|
          reaction_cards += player.find_cards_in_hand(reaction_card_name)
        end
        reaction_cards.each do |reaction_card|
          reaction_card.card.reaction(@game, player)
          TurnActionHandler.wait_for_card(reaction_card.card)
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
    has_lighthouse?(player) || has_moat?(player)
  end

  def has_lighthouse?(player)
    immune = player.turns.present? && player.turns[0].lighthouse
    if immune
      lighthouse = Card.by_name 'lighthouse'
      LogUpdater.new(@game).immune_to_attack(player, lighthouse.card_html)
    end
    immune
  end

  def has_moat?(player)
    immune = false
    moat = player.hand.select{ |card| card.name == 'moat' }.first
    if moat
      TurnActionHandler.wait_for_card(@card)
      options = [
        { text: 'Yes', value: 'yes' },
        { text: 'No', value: 'no' }
      ]
      action = TurnActionHandler.send_choose_text_prompt(@game, player, options, "Reveal #{moat.card.card_html}?".html_safe, 1, 1)
      TurnActionHandler.wait_for_response(@game)
      action = TurnAction.find_uncached action.id
      if action.response == 'yes'
        immune = true
        LogUpdater.new(@game).reveal(player, [moat], 'hand')
        LogUpdater.new(@game).immune_to_attack(player, moat.card.card_html)
      end
      action.destroy
    end
    immune
  end

end
