$ ->
  socket = new WebSocket("ws://#{window.location.host}/lobby/update")
  window.lobby = {}
  player_count_error = 'Game can not have more than 4 players.'

  # Propose Game
  $form = $("form#lobby")
  $form.on "submit", (event) ->
    event.preventDefault()
    player_ids = _.map($form.find("input:checked"), checkbox_value)
    if player_ids.length > 3
      alert player_count_error
    else
      socket.send(JSON.stringify(action: 'propose_game', player_ids: player_ids))

  # Chat Window
  $chat_form = $("form#chat")
  $chat_form.on "submit", (event) ->
    event.preventDefault()
    $input = $chat_form.find("input#message")
    message = $input.val()
    socket.send(JSON.stringify(action: 'chat', message: message))
    $input.val("")
  $chat_output = $("#lobby-chat")

  $proposal = $("#proposal")
  # Accept Game Proposal
  $proposal.on "click", "#accept", (event) ->
    event.preventDefault()
    game_id = get_game_id()
    socket.send(JSON.stringify(action: 'accept_game', game_id: game_id))
  # Reject Game Proposal
  $proposal.on "click", "#decline", (event) ->
    event.preventDefault()
    game_id = get_game_id()
    socket.send(JSON.stringify(action: 'decline_game', game_id: game_id))

  socket.onmessage = (event) ->
    response = JSON.parse event.data
    if response.action == 'refresh'
      lobby.refresh(response)
    else if response.action == 'propose'
      lobby.propose(response)
    else if response.action == 'player_count_error'
      alert player_count_error
    else if response.action == 'player_in_game_error'
      lobby.player_in_game_error(response)
    else if response.action == 'accept'
      alert "#{response.player.username} has accepted the game."
    else if response.action == 'decline'
      lobby.decline(response)
    else if response.action == 'timeout'
      lobby.timeout(response)
    else if response.action == 'accept_received'
      lobby.accept_received(response)
    else if response.action == 'accepted_game'
      window.location.replace "http://#{window.location.host}/game/#{response.game_id}"
    else if response.action == 'chat'
      lobby.chat(response)

  # Refresh Lobby
  window.lobby.refresh = (response) ->
    $('#players').html(HandlebarsTemplates['lobby/players'](response))

  # Render Game Proposal
  window.lobby.propose = (response) ->
    $('#propose-game').hide()
    $('#proposal').html(HandlebarsTemplates['lobby/game_proposal'](response))

  # Render Declined Game
  window.lobby.decline = (response) ->
    $('#propose-game').show()
    $('#proposal').html(HandlebarsTemplates['lobby/declined_game'](response))

  # Render Proposal Timeout
  window.lobby.timeout = (response) ->
    $('#propose-game').show()
    $('#proposal').html(HandlebarsTemplates['lobby/proposal_timeout'](response))

  # Render Accept Feedback
  window.lobby.accept_received = (response) ->
    $('#proposal-form-container').html(HandlebarsTemplates['lobby/accept_received'](response))

  # Render Player In Game Error
  window.lobby.player_in_game_error = (response) ->
    $('#proposal').html(HandlebarsTemplates['lobby/player_in_game_error'](response))

  # Chat Window
  window.lobby.chat = (response) ->
    $chat_output.append(response.message + "\n")
    $chat_output.scrollTop($chat_output[0].scrollHeight)

  checkbox_value = (checkbox) ->
    $(checkbox).val()

  get_game_id = =>
    $('#game-id').val()
