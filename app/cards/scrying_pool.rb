class ScryingPool < Card

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 2,
      potion: 1
    }
  end

  def type
    [:action, :attack]
  end

  def play(game, clone=false)
    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')

    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        @reveal = :first
        reveal(game, game.current_player)
        @log_updater.reveal(game.current_player, @revealed, 'deck')
        discard_card(game, game.current_player) unless @revealed.empty?
        @reveal = :second
        reveal(game, game.current_player)
        @log_updater.reveal(game.current_player, @revealed, 'deck')
        gain_revealed_cards(game, game.current_player) unless @revealed.empty?
        ActiveRecord::Base.connection.clear_query_cache
        TurnActionHandler.refresh_game_area(game, game.current_player.player)
      end
    }
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        @reveal = :first
        players.each do |player|
          reveal(game, player)
          @log_updater.reveal(player, @revealed, 'deck')
          discard_card(game, player) unless @revealed.empty?
          TurnActionHandler.wait_for_response(game)
          ActiveRecord::Base.connection.clear_query_cache
          TurnActionHandler.refresh_game_area(game, player.player)
        end
      end
    }
  end

  def discard_card(game, game_player)
    options = [
      { text: 'Yes', value: 'yes' },
      { text: 'No', value: 'no' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, "Discard #{@revealed.first.card.card_html}?".html_safe, 1, 1)
    TurnActionHandler.process_player_response(game, game_player, action, self)
  end

  def process_action(game, game_player, action)
    if action.response == 'yes'
      CardDiscarder.new(game_player, @revealed).discard
    else
      @revealed.first.update state: 'deck'
      @log_updater.put(game_player, @revealed, 'deck', false)
    end
  end

  def gain_revealed_cards(game, game_player)
    CardDiscarder.new(game_player, [@valid_card]).discard if @valid_card.present?
    revealed_cards = game_player.player_cards.revealed
    @log_updater.put(game_player, revealed_cards, 'hand', false)
    revealed_cards.update_all(state: 'hand') unless revealed_cards.empty?
  end

  private

  def reveal(game, player)
    @revealed = []
    reveal_cards(game, player)
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    if @reveal == :first
      @revealed.count == 1
    elsif @reveal == :second
      unless card.action?
        @valid_card = card
      end
      @valid_card.present?
    end
  end

  def reveal_finished?(game, player)
    if @reveal == :first
      @revealed.count == 1 || player.discard.count == 0
    elsif @reveal == :second
      @valid_card.present? || player.discard.count == 0
    end
  end

end
