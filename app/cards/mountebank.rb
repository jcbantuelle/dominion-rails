class Mountebank < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action, :attack]
  end

  def play(game, clone=false)
    game.current_turn.add_coins(2)
    @log_updater.get_from_card(game.current_player, '+$2')
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        players.each do |player|
          discard_curse(game, player)
          TurnActionHandler.wait_for_response(game)
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, player.player)
        end
      end
    }
  end

  def discard_curse(game, game_player)
    curse = game_player.hand.select{ |c| c.name == 'curse' }.first
    if curse.nil?
      give_cards(game, game_player)
    else
      options = [
        { text: 'Yes', value: 'yes' },
        { text: 'No', value: 'no' }
      ]
      action = TurnActionHandler.send_choose_text_prompt(game, game_player, options, "Discard #{curse.card.card_html}?".html_safe, 1, 1, 'discard')
      TurnActionHandler.process_player_response(game, game_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    if action.action == 'discard'
      if action.response == 'yes'
        curse = game_player.hand.select{ |c| c.name == 'curse' }.first
        CardDiscarder.new(game_player, [curse]).discard
      elsif action.response == 'no'
        give_cards(game, game_player)
      end
    end
  end

  def give_cards(game, player)
    give_card_to_player(game, player, 'curse', 'discard')
    give_card_to_player(game, player, 'copper', 'discard')
  end

end
