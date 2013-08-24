class LogUpdater

  def initialize(game)
    @game = game
  end

  def end_turn
    send_message 'end_turn'
  end

  def card_action(player, card, action, destination=nil)
    locals = {
      target_player: player,
      card: card,
      action: action,
      destination: destination
    }

    send_message('card_action', locals)
  end

  def draw(cards, player)
    locals = {
      target_player: player,
      cards: cards
    }
    send_message('draw_cards', locals)
  end

  def reveal(player, cards, source)
    locals = {
      target_player: player,
      cards: cards,
      source: source
    }
    send_message('reveal_cards', locals)
  end

  def put(player, cards, destination)
    locals = {
      target_player: player,
      cards: cards,
      destination: destination
    }
    send_message('put_cards', locals)
  end

  def get_from_card(player, message)
    locals = {
      target_player: player,
      message: message
    }
    send_message('get_from_card', locals)
  end

  def discard(player, cards, source=nil)
    locals = {
      target_player: player,
      cards: cards,
      source: source
    }
    send_message('discard_cards', locals)
  end

  def trash(player, cards)
    locals = {
      target_player: player,
      cards: cards
    }
    send_message('trash_cards', locals)
  end

  private

  def send_message(template, custom_locals = {})
    @game.game_players.each do |game_player|
      locals = {
        game: @game,
        player: game_player
      }.merge(custom_locals)

      message = Renderer.new.render "game/log/#{template}", locals
      WebsocketDataSender.send_game_data game_player.player, @game, log_message_json(message)
    end
  end

  def log_message_json(message)
    {
      action: 'log_message',
      log: message
    }.to_json
  end

end
