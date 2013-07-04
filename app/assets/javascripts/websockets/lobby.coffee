$ ->
  socket = new WebSocket("ws://#{window.location.host}/lobby/update")

  $form = $("form#lobby")
  $form.on "submit", (event) ->
    event.preventDefault()
    player_ids = _.map($form.find("input:checked"), checkbox_value)
    socket.send(JSON.stringify(action: 'propose', player_ids: player_ids))

  socket.onmessage = (event) ->
    response = JSON.parse(event.data)
    if response.action == 'refresh'
      refresh(response)
    else if response.action == 'propose'
      propose(response)

  refresh = (response) ->
    $('#players').empty()
    $('#players').append(HandlebarsTemplates['lobby/players'](response))

  propose = (response) ->
    $('#proposal').html(HandlebarsTemplates['lobby/game_proposal'](response))

  checkbox_value = (checkbox) ->
    $(checkbox).val()
