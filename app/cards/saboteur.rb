module Saboteur

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
    LogUpdater.new(game).custom_message(game.current_player, 'a douchebag for using Saboteur', 'be')
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        @trashed = []
        players.each do |player|
          reveal(game, player)
          gain_replacement(game, player) unless @trashed.nil?
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, player.player)
        end
      end
    }
  end

  def process_action(game, game_player, action)
    if action.response.empty?
      LogUpdater.new(game).custom_message(game_player, 'not to gain a card', 'choose')
    else
      card = GameCard.find action.response
      CardGainer.new(game, game_player, card.name).gain_card('discard')
    end
  end

  private

  def gain_replacement(game, player)
    card_cost = @trashed.calculated_cost(game, game.current_turn)
    available_cards = game.cards_costing_less_than(card_cost[:coin] - 1, card_cost[:potion])
    if available_cards.count == 0
      LogUpdater.new(game).custom_message(player, 'nothing because there are no cards available', 'gains')
    elsif available_cards.count == 1
      CardGainer.new(game, player, available_cards.first.name).gain_card('discard')
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, player, available_cards, "You may choose a card to gain:", 1)
      TurnActionHandler.process_player_response(game, player, action, self)
    end
  end

  def reveal(game, player)
    @revealed = []
    @trashed = nil
    reveal_cards(game, player)
    player.discard_revealed
    @log_updater.reveal(player, @revealed, 'deck', @trashed.nil?)
    CardTrasher.new(player, [@trashed]).trash(nil, true) if @trashed.present?
  end

  def process_revealed_card(card)
    game = card.game_player.game
    cost = card.calculated_cost(game, game.current_turn)
    if cost[:coin] > 2
      @trashed = card
    else
      card.update_attribute :state, 'revealed'
    end
    @trashed.present?
  end

  def reveal_finished?(game, player)
    @trashed.present? || player.discard.count == 0
  end

end
