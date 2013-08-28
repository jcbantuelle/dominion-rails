require 'spec_helper'

describe 'Platinum' do
  let(:card_name) { 'platinum' }

  include_context 'play card'

  describe '#play' do
    it 'gives +$5' do
      @subject.play_card
      @turn.reload
      expect(@turn.phase).to eq('treasure')
      expect(@turn.coins).to eq(5)
    end
  end
end
