class Thief < Card

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
  end

  def attack(game, players)
    @attack_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        @trashed = []
        players.each do |player|
          reveal(game, player)
          trash_treasure(game, player)
          TurnActionHandler.wait_for_response(game)
        end
        gain_trashed_treasures(game) unless @trashed.empty?
      end
    }
  end

  def process_action(game, game_player, action)
    if action.action == 'trash'
      process_trash_action(game, game_player, action)
    else
      process_gain_action(game, game_player, action)
    end
  end

  private

  def reveal(game, player)
    @revealed = []
    reveal_cards(game, player)
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 2
  end

  def reveal_finished?(game, player)
    @revealed.count == 2 || player.discard.count == 0
  end

  def trash_treasure(game, player)
    treasures = @revealed.select(&:treasure?)
    if treasures.count == 0
      @log_updater.reveal(player, @revealed, 'deck')
    else
      @log_updater.reveal(player, @revealed, 'deck')
      if treasures.count == 1
        @trashed += CardTrasher.new(player, treasures).trash
      else
        action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, treasures, "Choose which of #{player.username}'s treasures to trash:", 1, 1, 'trash')
        TurnActionHandler.process_player_response(game, player, action, self)
      end
    end
    revealed_cards = player.player_cards.revealed
    CardDiscarder.new(player, revealed_cards).discard
  end

  def gain_trashed_treasures(game)
    action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, @trashed, 'Choose which treasures you want to gain:', 0, 0, 'gain')
    TurnActionHandler.process_player_response(game, game.current_player, action, self)
  end

  def process_trash_action(game, game_player, action)
    trashed_card = PlayerCard.find action.response
    @trashed += CardTrasher.new(game_player, [trashed_card]).trash
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

  def process_gain_action(game, game_player, action)
    gained_cards = []
    gained_trash = GameTrash.where id: action.response.split
    gained_trash.each do |trash_card|
      gained_cards << PlayerCard.create(game_player: game_player, card: trash_card.card, state: 'discard')
      trash_card.destroy
    end
    LogUpdater.new(game).gain(game.current_player, gained_cards, 'trash')
  end
end
