require 'spec_helper'

describe 'Coppersmith' do
  let(:card_name) { 'coppersmith' }

  include_context 'play card'

  describe '#play' do
    it 'makes copper worth +$1 extra' do
      @subject.play_card
      @turn.reload
      expect(@turn.coppersmith).to eq(1)
    end
  end
end
