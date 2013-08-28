require 'spec_helper'

describe 'Gold' do
  let(:card_name) { 'gold' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'
    it 'gives +$3' do
      @subject.play_card
      @turn.reload
      expect(@turn.phase).to eq('treasure')
      expect(@turn.coins).to eq(3)
    end
  end
end
