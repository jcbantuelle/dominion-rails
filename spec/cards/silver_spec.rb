require 'spec_helper'

describe 'Silver' do
  let(:card_name) { 'silver' }

  include_context 'play card'

  describe '#play' do
    it 'updates the game state' do
      @subject.play_card
      @turn.reload
      expect(@turn.phase).to eq('treasure')
      expect(@turn.coins).to eq(2)
    end
  end
end
