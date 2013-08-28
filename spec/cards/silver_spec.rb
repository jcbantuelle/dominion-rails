require 'spec_helper'

describe 'Silver' do
  let(:card_name) { 'silver' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'
    it 'gives +$2' do
      @subject.play_card
      @turn.reload
      expect(@turn.phase).to eq('treasure')
      expect(@turn.coins).to eq(2)
    end
  end
end
