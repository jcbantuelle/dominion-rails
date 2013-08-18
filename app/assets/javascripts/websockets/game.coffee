$ ->
  socket = new WebSocket("ws://#{window.location.host + window.location.pathname}/update")
  window.game = {}

  $turn_actions = $('#turn-actions')
  $turn_actions.on "click", "#end-turn", (event) ->
    event.preventDefault()
    socket.send(JSON.stringify(action: 'end_turn'))

  $purchasable_cards = $('#kingdom-cards, #common-cards')
  $purchasable_cards.on "click", ".card", (event) ->
    event.preventDefault()
    socket.send(JSON.stringify(action: 'buy_card', card_id: $(this).attr('data-card-id')))

  $hand = $('#hand')
  $hand.on "click", ".hand-card", (event) ->
    event.preventDefault()
    socket.send(JSON.stringify(action: 'play_card', card_id: $(this).attr('id')))

  socket.onmessage = (event) ->
    response = JSON.parse event.data
    if response.action == 'refresh'
      game.refresh(response)
    else if response.action == 'end_turn'
      game.end_turn(response)
    else if response.action == 'play_card'
      game.play_card(response)
    else if response.action == 'buy_card'
      game.play_card(response)
    else if response.action == 'log_message'
      game.log_message(response)
    else if response.action == 'end_game'
      game.end_game(response)

  # Refresh Game
  window.game.refresh = (response) ->
    game.refresh_kingdom_cards(response)
    game.refresh_common_cards(response)
    game.refresh_turn_status(response)
    game.refresh_game_info(response)
    game.refresh_turn_actions(response)
    game.refresh_hand(response)
    game.refresh_end_game(response)
    game.refresh_tooltips()

  # End Turn
  window.game.end_turn = (response) ->
    game.refresh_turn_status(response)
    game.refresh_game_info(response)
    game.refresh_turn_actions(response)
    game.refresh_hand(response)
    game.refresh_tooltips()

  # Play Card
  window.game.play_card = (response) ->
    game.refresh_kingdom_cards(response)
    game.refresh_common_cards(response)
    game.refresh_turn_status(response)
    game.refresh_game_info(response)
    game.refresh_turn_actions(response)
    game.refresh_hand(response)
    game.refresh_tooltips()

  # Buy Card
  window.game.buy_card = (response) ->
    game.refresh_kingdom_cards(response)
    game.refresh_common_cards(response)
    game.refresh_turn_status(response)
    game.refresh_game_info(response)
    game.refresh_turn_actions(response)
    game.refresh_hand(response)
    game.refresh_tooltips()

  # End Game
  window.game.end_game = (response) ->
    $('<div id="finished-game"></div>').insertBefore('#action-area');
    $('#hand, #action-area').remove()
    game.refresh_end_game(response)

  # Log Message
  window.game.log_message = (response) ->
    $('#game-log').append(HandlebarsTemplates['game/log'](response.log))
    $('#game-log').scrollTop($('#game-log')[0].scrollHeight)

  window.game.refresh_kingdom_cards = (response)->
    $('#kingdom-cards').html(HandlebarsTemplates['game/cards'](response.kingdom_cards))

  window.game.refresh_common_cards = (response)->
    $('#common-cards').html(HandlebarsTemplates['game/cards'](response.common_cards))

  window.game.refresh_turn_status = (response)->
    $('#turn-status').html(HandlebarsTemplates['game/turn_status'](response))

  window.game.refresh_game_info = (response)->
    $('#draw-pile').html(HandlebarsTemplates['game/draw_pile'](response.deck_count))
    $('#discard-pile').html(HandlebarsTemplates['game/discard_pile'](response.discard_count))

  window.game.refresh_turn_actions = (response)->
    $('#turn-actions').html(HandlebarsTemplates['game/turn_actions'](response))

  window.game.refresh_hand = (response)->
    $('#hand').html(HandlebarsTemplates['game/hand'](response.hand))

  window.game.refresh_end_game = (response)->
    $('#finished-game').html(HandlebarsTemplates['game/end_game'](response))

  # Tooltip Refresh
  window.game.refresh_tooltips = ->
    $('.card-container .card').tooltip({
      position: 'bottom right',
      offset: [-66,5]
    })

    $('.hand-card').tooltip({
      position: 'bottom center',
      offset: [80,0]
    })
