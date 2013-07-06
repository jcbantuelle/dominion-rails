$ ->
  socket = new WebSocket("ws://#{window.location.host}/lobby/update")
  player_count_error = 'Game can not have more than 4 players.'

  $form = $("form#lobby")
  $form.on "submit", (event) ->
    event.preventDefault()
    player_ids = _.map($form.find("input:checked"), checkbox_value)
    if player_ids.length > 3
      alert player_count_error
    else
      socket.send(JSON.stringify(action: 'propose', player_ids: player_ids))

  socket.onmessage = (event) ->
    response = JSON.parse event.data
    if response.action == 'refresh'
      refresh(response)
    else if response.action == 'propose'
      propose(response)
    else if response.action == 'player_count_error'
      alert player_count_error

  refresh = (response) ->
    $('#players').empty()
    $('#players').append(HandlebarsTemplates['lobby/players'](response))

  propose = (response) ->
    $('#proposal').html(HandlebarsTemplates['lobby/game_proposal'](response))

  checkbox_value = (checkbox) ->
    $(checkbox).val()
