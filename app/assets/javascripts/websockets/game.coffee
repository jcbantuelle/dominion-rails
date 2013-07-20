$ ->
  socket = new WebSocket("ws://#{window.location.host + window.location.pathname}/update")
  window.game = {}

  socket.onmessage = (event) ->
    response = JSON.parse event.data
    if response.action == 'refresh'
      game.refresh(response)

  # Refresh Game
  window.game.refresh = (response) ->
    game.refresh_kingdom_cards(response)
    game.refresh_common_cards(response)
    game.refresh_tooltips()

  window.game.refresh_kingdom_cards = (response)->
    $('#kingdom-cards').html(HandlebarsTemplates['game/cards'](response.kingdom_cards))

  window.game.refresh_common_cards = (response)->
    $('#common-cards').html(HandlebarsTemplates['game/cards'](response.victory_cards))
    $('#common-cards').append(HandlebarsTemplates['game/cards'](response.treasure_cards))
    $('#common-cards').append(HandlebarsTemplates['game/cards'](response.miscellaneous_cards))

  # Tooltip Refresh
  window.game.refresh_tooltips = () ->
    $('.card-container .card').tooltip({
      position: 'bottom right',
      offset: [-66,5]
    })

    $('.hand-card li:last-child').tooltip({
      position: 'top center',
      offset: [-5,0]
    })