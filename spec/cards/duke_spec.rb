require 'spec_helper'

describe 'Duke' do
  let(:card_name) { 'duke' }

  describe '#value' do

    include_context 'victory card'

    it 'is worth 1 point per Duchy' do
      duchy = Card.create name: 'duchy'
      deck = []
      4.times do
        deck << PlayerCard.create(game_player: @game_player, card_id: duchy.id, state: 'deck')
      end

      expect(@card.value(deck)).to eq(4)
    end
  end

end
