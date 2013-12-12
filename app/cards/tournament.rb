class Tournament < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        @gain_prize = false
        @gain_bonus = true
        reveal_province(game)
        gain_prize(game) if @gain_prize
        gain_bonus(game) if @gain_bonus
      end
    }
  end

  def reveal_province(game)
    game.turn_ordered_players.each do |player|
      if player.find_card_in_hand('province')
        province = Card.by_name('province')
        options = [
          { text: 'Yes', value: 'yes' },
          { text: 'No', value: 'no' }
        ]
        action = TurnActionHandler.send_choose_text_prompt(game, player, options, "Reveal #{province.card_html}?".html_safe, 1, 1, 'reveal')
        TurnActionHandler.process_player_response(game, player, action, self)
      end
    end
  end

  def gain_prize(game)
    cards = game.game_prizes.to_a
    duchy = GameCard.by_game_id_and_card_name(game.id, 'duchy').first
    cards << duchy if duchy.remaining > 0
    if cards.empty?
      LogUpdater.new(game).custom_message(nil, 'But there are no cards to gain')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, cards, 'Choose a card to gain:', 1, 1, 'gain')
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def gain_bonus(game)
    CardDrawer.new(game.current_player).draw(1)
    game.current_turn.add_coins(1)
    @log_updater.get_from_card(game.current_player, '+$1')
  end

  def process_action(game, game_player, action)
    if action.action == 'reveal'
      if action.response == 'yes'
        province = game_player.find_card_in_hand('province')
        LogUpdater.new(game).reveal(game_player, [province], 'hand')
        if game_player.id == game.current_player.id
          @gain_prize = true
          CardDiscarder.new(game_player, [province]).discard('hand')
        else
          @gain_bonus = false
        end
      end
    elsif action.action == 'gain'
      duchy = GameCard.by_game_id_and_card_name(game.id, 'duchy').first
      if action.response == duchy.id.to_s
        give_card_to_player(game, game_player, 'duchy', 'deck')
      else
        prize = GamePrize.find(action.response)
        gain_prize_on_deck(game, game_player, prize)
      end
    end
  end

  def gain_prize_on_deck(game, game_player, prize_card)
    card = PlayerCard.create(game_player: game_player, card: prize_card.card, state: 'discard')
    put_card_on_deck(game, game_player, card)
    prize_card.destroy
  end
end
