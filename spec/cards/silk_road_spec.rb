require 'spec_helper'

describe 'Silk Road' do
  let(:card_name) { 'silk_road' }

  describe '#value' do

    include_context 'victory card'

    it 'is worth 1 point per 4 victory cards' do
      deck = []
      9.times do
        deck << PlayerCard.create(game_player: @game_player, card: @card, state: 'deck')
      end
      expect(@card.value(deck)).to eq(2)
    end
  end

end
