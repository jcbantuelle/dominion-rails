require 'spec_helper'

describe 'Copper' do
  let(:card_name) { 'copper' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'
    it 'gives +$1' do
      @subject.play_card
      @turn.reload
      expect(@turn.phase).to eq('treasure')
      expect(@turn.coins).to eq(1)
    end
  end
end
