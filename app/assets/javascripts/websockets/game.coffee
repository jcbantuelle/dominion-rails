$ ->
  #socket = new WebSocket("ws://#{window.location.host}/game/update")

  $('.card-container .card').tooltip({
    position: 'bottom right',
    offset: [-66,5]
  })

  #socket.onmessage = (event) ->
  #  response = JSON.parse event.data
