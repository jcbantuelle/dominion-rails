module Courtyard

  def starting_count(game)
    10
  end

  def cost(game)
    {
      coin: 2
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(3)
    TurnActionHandler.refresh_game_area(game, game.current_player.player)
    unless game.current_player.hand.empty?
      @play_thread = Thread.new {
        action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, game.current_player.hand, 'Choose a card to return to deck:', 1, 1)
        TurnActionHandler.process_player_response(game, game.current_player, action, self)
        ActiveRecord::Base.clear_active_connections!
      }
    end
  end

  def process_action(game, game_player, action)
    returned_card = PlayerCard.find action.response
    put_card_on_deck(game, game_player, returned_card)
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

end
