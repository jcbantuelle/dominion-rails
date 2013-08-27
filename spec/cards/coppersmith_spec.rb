require 'spec_helper'

describe 'Coppersmith' do
  let(:card_name) { 'coppersmith' }

  include_context 'play card'

  describe '#play' do
    it 'updates the game state' do
      @subject.play_card
      @turn.reload
      expect(@turn.coppersmith).to eq(1)
    end
  end
end
