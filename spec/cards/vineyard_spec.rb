require 'spec_helper'

describe 'Vineyard' do
  let(:card_name) { 'vineyard' }

  describe '#value' do

    include_context 'victory card'

    it 'is worth 1 point per 3 action cards' do
      deck = []
      action_card = Card.find(Card.create(name: 'village').id)
      7.times do
        deck << PlayerCard.create(game_player: @game_player, card: action_card, state: 'deck')
      end
      expect(@card.value(deck)).to eq(2)
    end
  end

end
