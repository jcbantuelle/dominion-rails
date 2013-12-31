class Vault < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(2)

    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        discard_for_coins(game)
        game.turn_ordered_players.each do |player|
          discard_two_cards(game, player) if player != game.current_player && player.hand.count > 0
        end
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'coin'
      discarded_cards = PlayerCard.where(id: action.response.split)
      card_count = discarded_cards.count
      CardDiscarder.new(game_player, discarded_cards).discard('hand')
      game.current_turn.add_coins(card_count)
      LogUpdater.new(game).get_from_card(game_player, "+$#{card_count}")
    elsif action.action == 'choose'
      if action.response == 'yes'
        if game_player.hand.count < 2
          CardDiscarder.new(game_player, game_player.hand).discard('hand')
        else
          action = TurnActionHandler.send_choose_cards_prompt(game, game_player, game_player.hand, 'Choose two cards to discard:', 2, 2, 'discard')
          TurnActionHandler.process_player_response(game, game_player, action, self)
        end
      end
    elsif action.action == 'discard'
      discarded_cards = PlayerCard.where(id: action.response.split)
      CardDiscarder.new(game_player, discarded_cards).discard('hand')
      CardDrawer.new(game_player).draw(1)
    end
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

  def discard_for_coins(game)
    action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, game.current_player.hand, 'Choose any number of cards to discard:', 0, 0, 'coin')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def discard_two_cards(game, game_player)
    options = [
      { text: 'Yes', value: 'yes' },
      { text: 'No', value: 'no' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(game, game_player, options, "Discard two cards?".html_safe, 1, 1, 'choose')
    TurnActionHandler.process_player_response(game, game_player, action, self)
  end

end
