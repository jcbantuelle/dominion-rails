module Websockets::Game::TurnActions

  def end_turn(data)
    if can_play?
      ApplicationController.games[@game.id][:thread] = Thread.new {
        ActiveRecord::Base.connection_pool.with_connection do
          TurnEnder.new(@game).end_turn
          ActiveRecord::Base.connection.clear_query_cache
          @game.reload
          send_end_turn_data
        end
      }
    end
  end

  def play_all_coin(data)
    if can_play?
      data['announce'] = false
      ApplicationController.games[@game.id][:thread] = Thread.new {
        ActiveRecord::Base.connection_pool.with_connection do
          played_coins = play_coin_from_hand(data)

          ActiveRecord::Base.connection.clear_query_cache
          @game.reload
          send_card_action_data('play_all_coin_json')

          played_coin_message(played_coins)
        end
      }
    end
  end

  def play_coin_from_hand(data)
    played_coins = {}
    ActiveRecord::Base.connection.clear_query_cache
    @game.reload
    @game.current_player.find_treasure_in_hand.each do |coin|
      played_coins[coin.name] ||= {
          html: coin.card.card_html,
          count: 0
      }
      played_coins[coin.name][:count] += 1
      data['card_id'] = coin.card.id
      play(data)
    end
    played_coins
  end

  def played_coin_message(played_coins)
    message = played_coins.map{ |name, attributes|
      "#{attributes[:count]} #{attributes[:html]}".html_safe
    }.join(', ')
    LogUpdater.new(@game).custom_message(@game.current_player, message.html_safe, 'play', false)
  end

  def play_card(data)
    if can_play?
      data['announce'] = true
      ApplicationController.games[@game.id][:thread] = Thread.new {
        ActiveRecord::Base.connection_pool.with_connection do
          ActiveRecord::Base.connection.clear_query_cache
          @game.reload
          play(data)
          ActiveRecord::Base.connection.clear_query_cache
          @game.reload
          send_card_action_data('play_card_json')
        end
      }
    end
  end

  def buy_card(data)
    if can_play?
      ApplicationController.games[@game.id][:thread] = Thread.new {
        ActiveRecord::Base.connection_pool.with_connection do
          card = GameCard.find(data['card_id'])
          gainer = CardGainer.new @game, @game.current_player, card.name
          if gainer.valid_buy?
            gainer.buy_card
            if @game.current_turn.buys == 0
              end_turn(nil)
            else
              ActiveRecord::Base.connection.clear_query_cache
              @game.reload
              send_card_action_data('buy_card_json')
            end
          end
        end
      }
    end
  end

  def action_response(data)
    action = TurnAction.find data['action_id']
    action.update finished: true, response: data['response']
  end

  private

  def can_play?
    @game.current_player.player_id == current_player.id
  end

  def play(data)
    player = CardPlayer.new @game, data['card_id'], false, false, nil, data['announce']
    if player.valid_play?
      player.play_card
    end
  end

  def send_card_action_data(action)
    @game.players.each do |player|
      WebsocketDataSender.send_game_data player, @game, send(action, @game, player)
    end
  end

  def send_end_turn_data
    @game.players.each do |player|
      json_content = @game.finished? ? end_game_json(@game, player) : end_turn_json(@game, player)
      WebsocketDataSender.send_game_data player, @game, json_content
    end
  end
end
