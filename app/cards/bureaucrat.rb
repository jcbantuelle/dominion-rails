class Bureaucrat < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 4
    }
  end

  def type
    [:action, :attack]
  end

  def play(game, clone=false)
    give_card_to_player(game, game.current_player, 'silver', 'deck')
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        players.each do |player|
          @victory_cards = player.hand.select(&:victory?)
          if @victory_cards.empty?
            @log_updater.reveal(player, player.hand, 'hand')
          else
            put_victory_card_on_deck(game, player)
          end
        end
      end
    }
  end

  def process_action(game, game_player, action)
    card = PlayerCard.find action.response
    reveal_card(game, game_player, card)
  end

  private

  def put_victory_card_on_deck(game, game_player)
    if @victory_cards.count == 1
      reveal_card(game, game_player, @victory_cards.first)
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game_player, @victory_cards, 'Choose a victory card to place on deck:', 1)
      TurnActionHandler.process_player_response(game, game_player, action, self)
    end
  end

  def reveal_card(game, game_player, card)
    @log_updater.reveal(game_player, [card], 'hand')
    put_card_on_deck(game, game_player, card)
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end
end
