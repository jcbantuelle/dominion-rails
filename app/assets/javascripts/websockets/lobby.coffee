$ ->
  socket = new WebSocket("ws://#{window.location.host}/lobby/update")

  #$form = $("form#lobby")
  # $form.on "submit", (event) ->
  #   event.preventDefault()
  #   $input = $form.find("input#message")
  #   message = $input.val()
  #   socket.send(JSON.stringify(message: message))
  #   $input.val("")

  # $output = $("#output")

  socket.onmessage = (event) ->
    response = JSON.parse(event.data)
    if response.action == 'refresh'
      refresh(response)

  refresh = (response) ->
    $('#players').empty()
    players = response.players
    add_to_lobby player for player in players

  add_to_lobby = (player) ->
    $('#players').append(HandlebarsTemplates['games/lobby_player'](player))
