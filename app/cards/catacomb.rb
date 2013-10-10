module Catacomb

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 5
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    reveal(game)
    @play_thread = Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do
        draw_or_discard(game)
      end
    }
  end

  def process_action(game, game_player, action)
    if action.response == 'keep'
      @revealed.each do |card|
        card.update_attribute :state, 'hand'
      end
      LogUpdater.new(game).custom_message(game_player, 'the drawn cards', 'keep')
    elsif action.response == 'discard'
      revealed_cards = game_player.player_cards.revealed
      CardDiscarder.new(game_player, revealed_cards).discard
      CardDrawer.new(game_player).draw(3)
    end
  end

  private

  def draw_or_discard(game)
    if @revealed.count == 0
      LogUpdater.new(game).custom_message(nil, 'But there are no cards to draw')
    else
      options = [
        { text: 'Put Cards Into Hand', value: 'keep' },
        { text: 'Discard and Draw 3', value: 'discard' }
      ]
      action = TurnActionHandler.send_choose_text_prompt(game, game.current_player, options, "Choose One:".html_safe, 1, 1)
      TurnActionHandler.process_player_response(game, game.current_player, action, self)
    end
  end

  def reveal(game)
    @revealed = []
    reveal_cards(game, game.current_player)
    @log_updater.look(game.current_player, @revealed, 'deck')
  end

  def process_revealed_card(card)
    card.update_attribute :state, 'revealed'
    @revealed.count == 3
  end

  def reveal_finished?(game, player)
    @revealed.count == 3 || game.current_player.discard.count == 0
  end

end
