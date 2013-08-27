require 'spec_helper'

describe 'Potion' do
  let(:card_name) { 'potion' }

  describe '#play' do
    include_context 'play card'

    it 'updates the game state' do
      @subject.play_card
      @turn.reload
      expect(@turn.phase).to eq('treasure')
      expect(@turn.potions).to eq(1)
    end
  end
end
