require 'spec_helper'

describe 'Woodcutter' do
  let(:card_name) { 'woodcutter' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'
    it 'gives +$2, +1 buy' do
      @subject.play_card
      @turn.reload
      expect(@turn.coins).to eq(2)
      expect(@turn.buys).to eq(2)
    end
  end
end
