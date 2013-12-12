$ ->
  socket = new WebSocket("ws://#{window.location.host + window.location.pathname}/update")
  window.game = {}

  $turn_actions = $('#turn-actions')
  $turn_actions.on "click", "#end-turn", (event) ->
    event.preventDefault()
    socket.send(JSON.stringify(action: 'end_turn'))
  $turn_actions.on "click", "#play-all-coin", (event) ->
    event.preventDefault()
    socket.send(JSON.stringify(action: 'play_all_coin'))

  $purchasable_cards = $('#kingdom-cards, #common-cards')
  $purchasable_cards.on "click", ".card", (event) ->
    event.preventDefault()
    socket.send(JSON.stringify(action: 'buy_card', card_id: $(this).attr('data-card-id')))

  # Chat Window
  $chat_form = $("form#chat")
  $chat_form.on "submit", (event) ->
    event.preventDefault()
    $input = $chat_form.find("input#message")
    message = $input.val()
    socket.send(JSON.stringify(action: 'chat', message: message))
    $input.val("")
  $chat_output = $("#game-chat")

  $hand = $('#hand')
  $hand.on "click", ".hand-card", (event) ->
    event.preventDefault()
    socket.send(JSON.stringify(action: 'play_card', card_id: $(this).attr('id')))

  socket.onmessage = (event) ->
    response = JSON.parse event.data
    if response.action == 'refresh'
      game.refresh(response)
    else if _.contains(['end_turn', 'play_all_coin', 'play_card', 'buy_card'], response.action)
      game.refresh_board(response)
    else if response.action == 'log_message'
      game.log_message(response)
    else if response.action == 'end_game'
      game.end_game(response)
    else if response.action == 'chat'
      game.chat(response)
    else if _.contains(['choose_cards', 'choose_text'], response.action)
      game.choose_options(response)
    else if response.action == 'order_cards'
      game.choose_card_order(response)

  # Refresh Game
  window.game.refresh = (response) ->
    game.refresh_board(response)
    game.refresh_end_game(response)

  # Refresh Board
  window.game.refresh_board = (response) ->
    game.refresh_kingdom_cards(response)
    game.refresh_common_cards(response)
    game.refresh_turn_status(response)
    game.refresh_game_info(response)
    game.refresh_turn_actions(response)
    game.refresh_hand(response)
    game.refresh_extra_info(response)
    game.refresh_tooltips()

  # End Game
  window.game.end_game = (response) ->
    game.refresh_board(response)
    $('<div id="finished-game"></div>').insertBefore('#action-area');
    $('#hand, #action-area').remove()
    game.refresh_end_game(response)

  # Choose Options
  window.game.choose_options = (response) ->
    $('#turn-actions').hide()
    $('#action-response').html(HandlebarsTemplates['game/'+response.action](response));
    $response_form = $("form#response-form")

    $checkboxes = $response_form.find('input')
    if response.maximum > 0
      $checkboxes.click ->
        too_many_selected = $checkboxes.filter(':checked').length >= response.maximum
        $checkboxes.not(':checked').attr('disabled', too_many_selected)

    $response_form.on "submit", (event) ->
      event.preventDefault()
      selected = new Array
      checkboxes = $(this).find('input:checked').each ->
        selected.push $(this).val()
      return false if game.outside_limits(selected.length, response)
      action_response = selected.join(' ')
      socket.send(JSON.stringify(action: 'action_response', response: action_response, action_id: response.action_id))
      $('#action-response').empty()
      $('#turn-actions').show()

  # Choose Card Order
  window.game.choose_card_order = (response) ->
    $('#turn-actions').hide()
    $('#action-response').html(HandlebarsTemplates['game/order_cards'](response));
    $response_form = $("form#response-form")
    $response_form.sortable()

    $response_form.on "submit", (event) ->
      event.preventDefault()
      card_ids = new Array
      $(this).find('input').each ->
        card_ids.push $(this).val()
      action_response = card_ids.join(' ')
      socket.send(JSON.stringify(action: 'action_response', response: action_response, action_id: response.action_id))
      $('#action-response').empty()
      $('#turn-actions').show()

  # Outside Limits
  window.game.outside_limits = (count, response) ->
    (response.minimum > 0 and count < response.minimum) or (response.maximum > 0 and count > response.maximum)

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

  window.game.refresh_extra_info = (response)->
    $('#extra-info').html(HandlebarsTemplates['game/info'](response))

  window.game.refresh_end_game = (response)->
    $('#finished-game').html(HandlebarsTemplates['game/end_game'](response))

  # Chat Window
  window.game.chat = (response) ->
    $chat_output.append(response.message + "\n")
    $chat_output.scrollTop($chat_output[0].scrollHeight)

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

    $('.prize-card').tooltip({
      position: 'bottom center'
      offset: [-100, -350]
    })
