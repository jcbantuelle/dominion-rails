class LogUpdater

  def initialize(game)
    @game = game
  end

  def end_turn
    send_message 'end_turn'
  end

  def outpost_turn
    locals = {
      outpost: Card.by_name('outpost')
    }
    send_message 'outpost_turn', locals
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

  def draw(cards, player, source=nil)
    locals = {
      target_player: player,
      cards: cards,
      source: source
    }
    send_message('draw_cards', locals)
  end

  def reveal(player, cards, source, discard=false)
    locals = {
      target_player: player,
      cards: cards,
      source: source,
      discard: discard
    }
    send_message('reveal_cards', locals)
  end

  def put(player, cards, destination, discard=true)
    locals = {
      target_player: player,
      cards: cards,
      destination: destination,
      discard: discard
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

  def trash(player, cards, source, discard)
    locals = {
      target_player: player,
      cards: cards,
      source: source,
      discard: discard
    }
    send_message('trash_cards', locals)
  end

  def immune_to_attack(player, source)
    locals = {
      target_player: player,
      source: source
    }
    send_message('immune_to_attack', locals)
  end

  def return_to_supply(player, cards)
    locals = {
      target_player: player,
      cards: cards
    }
    send_message('return_to_supply', locals)
  end

  def custom_message(player, message, action=nil)
    locals = {
      target_player: player,
      message: message,
      action: action
    }
    send_message('custom_message', locals)
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
