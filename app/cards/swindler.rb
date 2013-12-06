class Swindler < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 3
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
          reveal(game, player)
          if @revealed.empty?
            LogUpdater.new(game).custom_message(player, 'nothing to trash', 'have')
          else
            CardTrasher.new(player, @revealed).trash('deck')
            choose_new_card(game, player)
          end
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, player.player)
        end
      end
    }
  end

  def choose_new_card(game, game_player)
    trashed_card = @revealed.first
    trashed_card_cost = trashed_card.calculated_cost(game, game.current_turn)
    equal_cost_cards = game.cards_equal_to(trashed_card_cost)
    if equal_cost_cards.count == 0
      LogUpdater.new(game).custom_message(game_player, 'nothing because there are no same cost cards available', 'gain')
    elsif equal_cost_cards.count == 1
      CardGainer.new(game, game_player, equal_cost_cards.first.name).gain_card('discard')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, equal_cost_cards, "Choose a card for #{game_player.username} to gain:", 1, 1)
      TurnActionHandler.process_player_response(game, game_player, action, self)
    end
  end

  def process_action(game, game_player, action)
    card = GameCard.find action.response
    CardGainer.new(game, game_player, card.name).gain_card('discard')
  end

  private

  def reveal(game, player)
    @revealed = []
    reveal_cards(game, player)
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 1
  end

  def reveal_finished?(game, player)
    @revealed.count == 1 || player.discard.count == 0
  end

end
