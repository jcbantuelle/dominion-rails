require 'spec_helper'

describe 'Gardens' do
  let(:card_name) { 'garden' }

  describe '#value' do

    include_context 'victory card'

    it 'is worth 1 point per 10 cards' do
      deck = []
      25.times do |i|
        deck << i
      end

      expect(@card.value(deck)).to eq(2)
    end
  end

end
