module Websockets::Game::Refresh

  def refresh_game
    @game.players.each do |player|
      ApplicationController.games[@game.id][player.id].send_data({
        action: 'refresh',
        kingdom_cards: game_cards('kingdom'),
        victory_cards: game_cards('victory'),
        treasure_cards: game_cards('treasure'),
        miscellaneous_cards: [@game.curse_card]
      }.to_json) if ApplicationController.games[@game.id][player.id]
    end
  end

  private

  def game_cards(type)
    cards = []
    sort_cards(@game.send("#{type}_cards")).each do |card|
      cards << {
        name: card.name,
        type_class: card.type_class,
        cost: card.cost[:coin],
        remaining: card.remaining,
        title: card.name.titleize
      }
    end
    cards
  end

  def sort_cards(cards)
    cards.sort{ |a, b| b.cost[:coin] <=> a.cost[:coin] }
  end

end
