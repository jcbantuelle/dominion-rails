require 'spec_helper'

describe 'Harem' do
  let(:card_name) { 'harem' }

  describe '#play' do

    include_context 'play card'

    it 'gives +$2' do
      @subject.play_card
      @turn.reload
      expect(@turn.phase).to eq('treasure')
      expect(@turn.coins).to eq(2)
    end
  end

  describe '#value' do

    include_context 'victory card'

    it 'is worth 2 points' do
      expect(@card.value(nil)).to eq(2)
    end
  end

end
