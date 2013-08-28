require 'spec_helper'

describe 'Bridge' do
  let(:card_name) { 'bridge' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'
    it 'gives +$1, +1 buy, and reduces card costs by $1' do
      @subject.play_card
      @turn.reload
      expect(@turn.coins).to eq(1)
      expect(@turn.buys).to eq(2)
      expect(@turn.global_discount).to eq(1)
    end
  end
end
