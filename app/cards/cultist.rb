module Cultist

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action, :attack, :looter]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(2)

    cultists = game.current_player.find_cards_in_hand('cultist')
    if cultists.count > 0
      @play_thread = Thread.new {
        ActiveRecord::Base.connection_pool.with_connection do
          options = [
            { text: 'Yes', value: 'yes' },
            { text: 'No', value: 'no' }
          ]
          action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, "Play a cultist?".html_safe, 1, 1)
          TurnActionHandler.process_player_response(game, game.current_player, action, self)
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, game.current_player.player)
        end
      }
    end
  end

  def attack(game, players)
    players.each do |player|
      give_card_to_player(game, player, 'ruins', 'discard')
    end
  end

  def process_action(game, game_player, action)
    if action.response == 'yes'
      card = Card.by_name 'cultist'
        CardPlayer.new(game, card.id, true).play_card
    end
  end

  def trash_reaction(game, player)
    CardDrawer.new(player).draw(3, true, self)
  end

end
