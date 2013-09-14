module Vagrant

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 2
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(1)

    game.current_turn.add_actions(1)
    @log_updater.get_from_card(game.current_player, '+1 action')

    @revealed = []
    reveal_cards(game, game.current_player)
    @log_updater.reveal(game.current_player, @revealed, 'deck')
    @log_updater.put(@card.game_player, [@card], 'hand', false) if @card
  end

  def process_revealed_card(card)
    if card.curse? || card.victory? || card.shelter? || card.ruins?
      card.update_attribute :state, 'hand'
      @card = card
    end
    true
  end

  def reveal_finished?(game, player)
    @revealed.count == 1 || game.current_player.empty_discard?
  end

end
