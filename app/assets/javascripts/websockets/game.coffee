$ ->
  #socket = new WebSocket("ws://#{window.location.host}/game/update")

  $('.card-container .card').tooltip({
    position: 'bottom right',
    offset: [-66,5]
  })

  $('.hand-card li:last-child').tooltip({
    position: 'top center',
    offset: [-5,0]
  })

  #socket.onmessage = (event) ->
  #  response = JSON.parse event.data
