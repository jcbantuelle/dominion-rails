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
      socket.send(JSON.stringify(action: 'propose', player_ids: player_ids))

  $proposal = $("#proposal")
  # Accept Game Proposal
  $proposal.on "click", "#accept", (event) ->
    event.preventDefault()
    game_id = get_game_id()
    socket.send(JSON.stringify(action: 'accept', game_id: game_id))
  # Reject Game Proposal
  $proposal.on "click", "#decline", (event) ->
    event.preventDefault()
    game_id = get_game_id()
    socket.send(JSON.stringify(action: 'decline', game_id: game_id))

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

  checkbox_value = (checkbox) ->
    $(checkbox).val()

  get_game_id = =>
    $('#game-id').val()
