module Thief

  def starting_count(game)
    10
  end

  def cost(game)
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
    Thread.new {
      @trashed = []
      players.each do |player|
        reveal(game, player)
        trash_treasure(game, player)
        wait_for_response(game)
      end
      gain_trashed_treasures(game) unless @trashed.empty?
      ActiveRecord::Base.clear_active_connections!
    }
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
      @log_updater.reveal(player, @revealed, 'deck', true)
    else
      @log_updater.reveal(player, @revealed, 'deck', false)
      if treasures.count == 1
        @trashed += CardTrasher.new(player, treasures).trash(nil, true)
      else
        action = send_choose_cards_prompt(game, game.current_player, treasures, "Choose which of #{player.username}'s treasures to trash:", 1, 1, 'trash')
        process_player_response(game, player, action)
      end
    end
  end

  def gain_trashed_treasures(game)
    action = send_choose_cards_prompt(game, game.current_player, @trashed, 'Choose which treasures you want to gain:', 0, 0, 'gain')
    process_player_response(game, game.current_player, action)
  end

  def process_action(game, game_player, action)
    if action.action == 'trash'
      process_trash_action(game, game_player, action)
    else
      process_gain_action(game, game_player, action)
    end
  end

  def process_trash_action(game, game_player, action)
    trashed_card = PlayerCard.find action.response
    @trashed += CardTrasher.new(game_player, [trashed_card]).trash(nil, true)
    update_player_hand(game, game_player.player)
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
