class NobleBrigand < Card

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
    game.current_turn.add_coins(1)
    LogUpdater.new(game).get_from_card(game.current_player, '+$1')
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
    process_trash_action(game, game_player, action) if action.action == 'trash'
  end

  def gain_event(game, player, event)
    if event == 'buy'
      attacked_players = game.turn_ordered_players.reject{ |p| p.id == player.id }
      attack(game, attacked_players)
    end
  end

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
    treasures = @revealed.select{ |c| %w(silver gold).include?(c.name) }
    LogUpdater.new(game).reveal(player, @revealed, 'deck')
    if treasures.count == 0
      give_card_to_player(game, player, 'copper', 'discard')
    elsif treasures.count == 1
      @trashed += CardTrasher.new(player, treasures).trash
    else
      action = TurnActionHandler.send_choose_cards_prompt(game, game.current_player, treasures, "Choose which of #{player.username}'s treasures to trash:", 1, 1, 'trash')
      TurnActionHandler.process_player_response(game, player, action, self)
    end
    revealed_cards = player.player_cards.revealed
    CardDiscarder.new(player, revealed_cards).discard
  end

  def process_trash_action(game, game_player, action)
    trashed_card = PlayerCard.find action.response
    @trashed += CardTrasher.new(game_player, [trashed_card]).trash
    ActiveRecord::Base.connection.clear_query_cache
    TurnActionHandler.refresh_game_area(game, game_player.player)
  end

  def gain_trashed_treasures(game)
    gained_cards = []
    gained_trash = GameTrash.where id: @trashed.collect(&:id)
    gained_trash.each do |trash_card|
      gained_cards << PlayerCard.create(game_player: game.current_player, card: trash_card.card, state: 'discard')
      trash_card.destroy
    end
    LogUpdater.new(game).gain(game.current_player, gained_cards, 'trash')
  end
end
